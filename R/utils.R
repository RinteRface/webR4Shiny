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
  # copy major R package elements
  file.copy("./R", path, recursive = TRUE)
  file.copy("./inst", path, recursive = TRUE)
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

#' Write app files to webr-shiny.js
#'
#' This allows to programmatically
#' generate a list of file to write in
#' the webR virtual file system
#'
#' @param path Path containing the Shiny webR installation.
#'
#'@keywords internal
write_app_files_to_js <- function(path) {
  # Reset js file
  file.copy(
    system.file("js/webr-shiny.js", package = "webR4Shiny"),
    "./webr"
  )
  # Read file
  shiny_js <- file.path(path, "webr-shiny.js")
  plop <- readLines(shiny_js)

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

  # Replace anchor by relevent files from R
  tmp_plop <- sub(
    "// <APP_FILES>",
    sprintf("const appFiles = %s;", app_files),
    plop
  )

  # Write to original file
  writeLines(tmp_plop, shiny_js)
}
