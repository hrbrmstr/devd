#' Start up a devd process
#'
#' The creates a background `devd` process and returns a `processx` handle to it.
#'
#' The default configuration (which should cover most use-cases) is to:
#'
#' - have the current working directory be the only route
#' - open an OS browser on process creation
#' - enable full cross-domain resource support
#'
#' The returned [processx::process()] object lets you introspect the process, kill the
#' process and return the last filled buffer from the error and "access" logs.
#'
#' NOTE: IF you restart, terminate, close, etc the calling R process that started
#' an underlying `devd` process you will need to start `devd` again (it's a child
#' process of R). This is intentional as it should prevent you from leaving
#' stale `devd` processes hanging around.
#'
#' @md
#' @param routes a character vector of `devd` [routes](https://github.com/cortesi/devd#routes) to setup
#' @param log_headers Log HTTP headers for each rquest
#' @param live_reload When `live_reload` is enabled, `devd` injects a small script into HTML pages, just before the closing head tag. The script listens for change notifications over a websocket connection, and reloads resources as needed. No browser addon is required, and `live_reload` works even for reverse proxied apps. If only changes to CSS files are seen, devd will only reload external CSS resources, otherwise a full page reload is done
#' @param live_watch Enales `live_reload` and watch for static file changes
#' @param basic_auth Supply a vector of `c("username", "password")` to enable basic auth for server (forces all requests to be authenticated)
#' @param open_browser if `TRUE` then your default OS browser will be launched and pointed to the main route path
#' @param tls Serve TLS with auto-generated self-signed certificate (in `~/.devd.cert`)
#' @param crossdomain if `TRUE` then we set the CORS header `Access-Control-Allowed: *`
#' @return `processx` process object
#' @export
#' @examples \dontrun{
#' dd <- devd_start()
#' devd_log(dd)
#' devd_stop(dd)
#' }
devd_start <- function(routes = ".", log_headers = FALSE, live_reload = FALSE,
                       live_watch = FALSE, basic_auth = NULL, open_browser = TRUE,
                       tls = FALSE, crossdomain = TRUE) {

  name <-  uuid::UUIDgenerate()

  devd_run_dir <- app_dir("rdevd")$config()
  devd_log_dir <- app_dir("rdevd")$log()

  start_time <- Sys.time()

  args <- c()

  if (open_browser) args <- c(args, "--open")
  if (log_headers) args <- c(args, "--logheaders")
  if (live_reload) args <- c(args, "--livereload")
  if (live_watch) args <- c(args, "--livewatch")
  if (tls) args <- c(args, "--tls")
  if (crossdomain) args <- c(args, "--crossdomain")
  if (length(basic_auth)>0) args <- c(args, sprintf("--password=%s:%s", basic_auth[1], basic_auth[2]))

  args <- c(args, routes)

  devd <-  processx::process$new(
    command = file.path(devd_run_dir, "devd"),
    args = args,
    stdout = "|",
    stderr = "|",
    # stdout = file.path(devd_log_dir, sprintf("%s.log", as.numeric(start_time))),
    # stderr = file.path(devd_log_dir, sprintf("%s.err", as.numeric(start_time))),
    windows_hide_window = TRUE
  )

  .pkgenv$ctrl$procs <- c(.pkgenv$ctrl$procs,
                          purrr::set_names(list(
                            list(
                              process=devd,
                              args=args
                              # log=file.path(devd_log_dir, sprintf("%s.log", as.numeric(start_time))),
                              # err=file.path(devd_log_dir, sprintf("%s.err", as.numeric(start_time)))
                            )
                          ), name))
  Sys.sleep(2)

  message(grep("Listening on", devd$read_output_lines(), ignore.case=TRUE, value=TRUE))

  invisible(devd)

}

#' Retrieve current "access log" buffer
#'
#' Returns (invisibly) a character vector of the "access log" lines from `devd` since
#' the last call to this function.
#'
#' @param p a [processx::process()] object (the return value from [devd_start])
#' @param view view the log contents in the console as well as return it as a character vector?
#' @return (invisibly) a character vector of the current "access log" lines buffer
#' @export
devd_log <- function(p, view=TRUE) {
 log_lines <- p$read_output_lines()
 if (view) message(paste0(log_lines, collapse="\n"))
 invisible(log_lines)
}

#' Stop a running devd process
#'
#' @param p a [processx::process()] object (the return value from [devd_start])
#' @export
#' @examples \dontrun{
#' dd <- devd_start()
#' devd_log(dd)
#' devd_stop(dd)
#' }
devd_stop <- function(p) {

  p$kill(grace = 0)

}