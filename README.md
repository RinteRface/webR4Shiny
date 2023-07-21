# webR4Shiny
Setup webR compatible infrastructure in your Shiny package project. This package is based on George Stagg's work around `{webR}`, particularly
this [repository](https://github.com/georgestagg/shiny-standalone-webr-demo) for deploying Shiny apps on Netlify.

## Installation

To get `{webR4Shiny}`:

```r
remotes::install_github("RinteRface/webR4Shiny")
```

Note that pre-compiled packages for WebAssembly are downloaded from `https://webr-cran.rinterface.com/`. This repository only contains
`{shiny}`, Shiny-related packages (httpuv, ...) and few RinteRface packages such as `{bs4Dash}`.

If you miss your favorite package, raise an issue [here](https://github.com/RinteRface/rinterface-webr-repo/issues). It is also
very possible that some package will not be available here for technical reasons.

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

