.pkgenv <- new.env(parent=emptyenv())

.onAttach <- function(...) {
  ctrl <- list()
  assign("ctrl", ctrl, envir=.pkgenv)
}
