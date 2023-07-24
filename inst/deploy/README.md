# How to deploy your app

## Run it locally

cd to `./webr` and run `make` to serve the app locally.
Browse to `localhost:8080` to view the app.

## Deploy on Netlify

Link your repo to Netlify and deploy the `./webr` folder only.

## Notes

Don't forget that there are few tweaks necessary to make it possible to work:

- We can't use `pkgload::load_all()` as in the usual `{golem}`
`app.R` file because local packages can't be installed on webR (we would need
a compiler for wasm). So we rely on the `{shiny}` autoload feature since 1.5.0, to load all files from the R folder (except the autoload one, which is not uploaded to the webR VFS).
- `{golem}` `app_sys()` also needs some tweaks since we can't do `system.file(..., package = "<local_package_name>)`, the package being
impossible to install locally.
- `golem::favicon()` does not seem to work, likely because of an issue
between `{fs}` and `webR` so we commented it out. 
