# webR4Shiny
Setup webR compatible infrastructure in your Shiny package project.

## Installation

To get `{webR4Shiny}`:

```r
remotes::install_github("RinteRface/webR4Shiny")
```

## Workflow

`{webR4Shiny}` is designed to work for `{golem}` powered Shiny apps.
Under the project root, run:

```r
init_shiny_webr()
```

This installs all files needed to have a webR compatible Shiny app by default
under `./webr`.

Each time you change the code within your package (R, inst, ...), you have to run:

```r
update_shiny_webr("<WEBR_PATH>")
```

`<WEBR_PATH>` being either the default location, `./webR` or any valid
alternative of your choice.

Finally, to cleanup the webR installation run:

```r
remove_shiny_webr("<WEBR_PATH>")
```
