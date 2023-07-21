#'@keywords internal
copy_assets <- function(type, copy_path) {
  files_path <- system.file(type, package = "webR4Shiny")
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
  file.copy("./DESCRIPTION", path)
  file.copy("./NAMESPACE", path)

  # This does not necessarily exist ...
  if (file.exists("./app.R")) {
    file.copy("./app.R", path)
  }
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
    "\"",
    "'",
    jsonlite::toJSON(
      list.files(
        file.path(path, app),
        recursive = TRUE,
        full.names = TRUE
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
