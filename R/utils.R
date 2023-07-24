#'@keywords internal
copy_assets <- function(type, copy_path) {
  files_path <- list.files(
    system.file(type, package = "webR4Shiny"),
    full.names = TRUE
  )
  file.copy(from = files_path, to = copy_path, recursive = TRUE)
}

#'@keywords internal
copy_js_assets <- function(path) {
  copy_assets(type = "js", path)
}

#'@keywords internal
copy_html_assets <- function(path) {
  copy_assets(type = "html", path)
}

#'@keywords internal
copy_r_assets <- function(path) {
  copy_assets(type = "R", path)
}

#'@keywords internal
copy_deploy_assets <- function(path) {
  copy_assets(type = "deploy", path)
}

#'@keywords internal
copy_local_app_assets <- function(path) {
  # Exclude disable autoload from copy
  exlude <- list.files("./R", pattern = ".autoload", full.names = TRUE)
  r_files <- list.files("./R", full.names = TRUE)
  r_files <- r_files[!r_files %in% exlude]
  # copy major R package elements
  dir.create(file.path(path, "R"))
  file.copy(r_files, file.path(path, "R"), recursive = TRUE)
  file.copy("./inst", path, recursive = TRUE)
  file.copy("./DESCRIPTION", path)
  # We don't need anything else since we can't
  # install the package locally due to webR limitations ...
}

#' Comment out favicon
#'
#' In app_ui.R, golem uses favicon,
#' which does not work well with webR,
#' likely because of the fs package (to check).
#' This function will comment this line so the app UI
#' prints correctly.
#'
#'@keywords internal
comment_golem_favicon <- function(path) {
  app_ui_file <- file.path(path, "R/app_ui.R")
  tmp_ui <- readLines(app_ui_file)
  tmp_ui <- sub("favicon", "# favicon", tmp_ui)
  writeLines(tmp_ui, app_ui_file)
}

#' Edit golem internal app_sys
#'
#' app_sys calls system.file on the local
#' package which can't work because the pkg
#' can't be install locally due to webR restrictions.
#' We overwrite it by a simple function which returns
#' the provided path prefixed by inst, where app assets
#' are found in a golem app.
#'
#'@keywords internal
edit_app_sys <- function(path) {
  app_config_file <- file.path(path, "R/app_config.R")
  tmp <- readLines(app_config_file)

  # Replace line that fails with webR (system.file)
  # since we can't install the local package.
  fun_def_index <- grep("app_sys", tmp)[[1]]
  replace_index <- fun_def_index + 1
  tmp[[replace_index]] <- "  # system.file with local pkg does not work
  sprintf(\"inst/%s\", list(...))"
  writeLines(tmp, app_config_file)
}

#' Find package imports
#'
#' Read the DESCRIPTION file and look for
#' any imports. Returns a vector of R dependencies.
#'
#'@keywords internal
find_pkg_imports <- function(path) {
  desc <- readLines(file.path(path, "DESCRIPTION"))
  imports_start <- grep("^Imports: (.*)", desc)
  if (length(imports_start) == 0) {
    stop("This package does not have any 'Imports' field.")
  }
  imports_end <- NULL
  for (i in seq_along(desc)) {
    if (imports_start + i <= length(desc)) {
      tmp <- grepl("    ", desc[[imports_start + i]])
      if (!tmp) {
        imports_end <- i + imports_start - 1
        break
      }
    } else {
      imports_end <- i + imports_start - 1
      break
    }
  }
  imports_start <- imports_start + 1

  # cleanup package versions
  tmp_res <- strsplit(desc[imports_start:imports_end], " ")
  tmp_res <- vapply(
    tmp_res,
    function(el) {
      el[[length(el) - 2]]
    },
    FUN.VALUE = character(1)
  )
  trimws(gsub("),", "", tmp_res))
}

#' Write shiny-webr.js file
#'
#' Write app deps and files with  \link{set_app_deps} and
#' \link{set_app_files}.
#'
#' @param path Path containing the Shiny webR installation.
#'
#'@keywords internal
write_webr_js <- function(path) {
  # Reset js file only if update it FALSE
  file.copy(
    system.file("js/webr-shiny.js", package = "webR4Shiny"),
    path
  )

  # Read file
  shiny_js <- file.path(path, "webr-shiny.js")
  conn <- readLines(shiny_js)
  # Add app deps
  conn <- set_app_deps(file.path(path, "app"), conn)
  # Add app files
  conn <- set_app_files(path, conn)

  # Write
  writeLines(conn, shiny_js)
}

#' Get app package dependencies to webr-shiny.js
#'
#' This allows to programmatically
#' write all the necessaries app dependencies to
#' the JS file and load them with library. This is necessary
#' because we can't install the local package from source so
#' we can't benefit from the NAMESPACE (imports).
#'
#' @inheritParams write_webr_js
#' @param conn webr-shiny.js content.
#'
#'@keywords internal
set_app_deps <- function(path, conn) {
  deps <- find_pkg_imports(path)
  # Write to original file at the given location
  sub(
    "# <APP_DEPS>",
    paste(sprintf("library(%s)", deps), collapse = "\n  "),
    conn
  )
}

#' Get app files within the webR installation
#'
#' This allows to programmatically
#' generate a list of file to write in
#' the webR virtual file system
#'
#' @inheritParams set_app_deps
#'
#'@keywords internal
set_app_files <- function(path, conn) {
  # List all files recursively and get full path
  app_files <- gsub(
    sprintf("%s/", path),
    "",
    gsub(
      "\"",
      "'",
      jsonlite::toJSON(
        list.files(
          file.path(path, "app"),
          recursive = TRUE,
          full.names = TRUE
        )
      )
    )
  )

  # Replace anchor by relevant files from R
  sub(
    "// <APP_FILES>",
    sprintf("const appFiles = %s;", app_files),
    conn
  )
}
