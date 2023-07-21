#' Create a webR compatible scaffold
#'
#' @param path Path to setup the webR installation.
#' @param copy_app_files Whether to copy the Shiny app package main
#' assets (R folder, inst, NAMESPACE and DESCRIPTION). Default
#' to TRUE. If FALSE, it will only copy the webR JS assets and html
#' elements.
#'
#' @export
init_shiny_webr <- function(path = "./webr", copy_app_files = TRUE) {
  is_package <- file.exists("./DESCRIPTION")
  if (!is_package) stop("Not a package ...")

  if (dir.exists(path)) {
    stop(
      "Already a webr compatible app. Please run update_shiny_webr to
      update your local installation."
    )
  } else {
    dir.create(file.path(path, "app"), recursive = TRUE)
  }

  # Copy webR assets
  copy_js_assets(path)
  copy_r_assets(path)
  copy_html_assets(path)
  copy_deploy_assets(path)

  if (copy_app_files) {
    # Copy local app assets
    copy_local_app_assets(file.path(path, "app"))
    # Get list of all app files and
    # inject them inside webr-shiny.js
    write_app_files_to_js(path)
  }


  # Put everything in webR to avoid adding
  # to many files in the .Rbuildignore
  usethis::use_build_ignore(
    c(
      cicd_ignore,
      sub("./", "", path)
    )
  )
}

#' Update a webR compatible scaffold
#'
#' Run each time you change any of the R
#' supporting file or inst elements.
#'
#' @inheritParams init_shiny_webr
#'
#' @export
update_shiny_webr <- function(path = "./webr", copy_app_files = TRUE) {
  remove_shiny_webr(path)
  init_shiny_webr(path, copy_app_files)
}

#' Cleanup the webR installation
#'
#' @param path Path to cleanup containing the webR installation.
#'
#' @export
remove_shiny_webr <- function(path = "./webr") {
  # Prompt user choice
  allow_delete <- menu(
    c("Yes", "No"),
    title = sprintf(
      "Do you want to cleanup your webR installation in %s?
      This will remove all files.",
      path
    )
  ) == 1

  if (allow_delete) {
    unlink(path, recursive = TRUE)
  } else {
    message("Aborting cleanup ...")
  }
}
