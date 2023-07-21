#' Create a webR compatible scaffold
#'
#' @param path Shiny app path.
#'
#' @export
scaffold_webr <- function(path) {
  is_package <- file.exists("./DESCRIPTION")
  if (!is_package) stop("Not a package ...")

  if (dir.exists("webr")) {
    stop("Already a webr compatible app")
  } else {
    dir.create("./webr/app", recursive = TRUE)
  }

  # Copy webR assets
  copy_js_assets("./webr")
  copy_r_assets("./webr")
  copy_html_assets("./webr")
  copy_deploy_assets("./webr")

  # Copy local app assets
  copy_local_app_assets("./webr/app")

  write_app_files_to_js()

  # Put everything in webR to avoid adding
  # to many files in the .Rbuildignore
  usethis::use_build_ignore(
    c(
      cicd_ignore,
      "webr"
    )
  )
}

#' Cleanup the webR installation
#'
#' @export
reset_webr <- function() {
  allow_delete <- menu(
    c("Yes", "No"),
    title = "Do you want to cleanup your webR installation in ./webr?"
  ) == 1
  if (answer) {
    unlink("./webr", recursive = TRUE)
  } else {
    message("Aborting cleanup ...")
  }
}
