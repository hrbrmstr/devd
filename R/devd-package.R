#' Install, Start and Stop 'devd' Instances
#'
#' The 'devd' <https://github.com/cortesi/devd> utility is "a web daemon for
#' developers". It is written in the 'Go' programming language and distributed in both
#' source and statically-linked, zero-dependency binary form. It's more lightweight
#' than 'node.js' or 'Python' equivalents and designed to support front-end development
#' tasks. It is a good companion for developing 'htmlwidgets' or other web-content.
#'
#' The intent of this package is meant to make it dirt simple to fire up a simple web
#' server in the backround along with a bona-fide system web browser from R (i.e. no need to even use the RStudio new built-in terminal) and also get access to the access log from it.
#'
#' A primary use-case is to use R to generate data for interactive D3 visualizations (not the `htmlwidget` kind, but one-off, special-purpose ones) and also use RStudio for
#' editing the HTML/CSS/JS resources (RStudio R Projects are great ways to keep web projects organized).
#'
#' It's also handy when doing something like the above and also want to test it with someting like [fiery](https://github.com/thomasp85/fiery) as a back-end API.
#'
#' @md
#' @name devd
#' @docType package
#' @author Bob Rudis (bob@@rud.is)
#' @import purrr httr rappdirs processx
#' @importFrom jsonlite fromJSON
#' @importFrom utils untar
#' @importFrom uuid UUIDgenerate
NULL
