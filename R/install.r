#' Install devd server for your platform
#'
#' This function will attempt to create local directories to store the `devd`
#' Go binary in and for logs to be kept. It always pulls the latest version of `devd`
#' and only has support for 64-bit macOS, Windows or Linux environments.
#'
#' @export
install_devd <- function() {

  res <- httr::GET("https://api.github.com/repos/cortesi/devd/releases/latest")
  httr::stop_for_status(res)
  res <- httr::content(res)

  os <- .Platform$OS.type
  if (os != "windows") {
    is_darwin <- grepl("darwin", Sys.info()["sysname"], ignore.case=TRUE)
    os <- if (is_darwin) "osx" else "windows"
  }

  os <- sprintf("%s64", os)

  map_chr(res$assets, "browser_download_url") %>% keep(~grepl(os, .x)) -> dl_url

  message(sprintf("Downloading devd version %s...", res$tag_name))

  devd_run_dir <- app_dir("rdevd")$config()
  devd_log_dir <- app_dir("rdevd")$log()

  dir.create(devd_run_dir, recursive=TRUE, showWarnings=FALSE)
  dir.create(devd_log_dir, recursive=TRUE, showWarnings=FALSE)

  download.file(dl_url, file.path(devd_run_dir, basename(dl_url)))

  utils::untar(file.path(devd_run_dir, basename(dl_url)), exdir=devd_run_dir)

  tar_path <- grep("64$", list.dirs(devd_run_dir), value=2)

  file.rename(file.path(tar_path, "devd"), file.path(devd_run_dir, "devd"))

  if (file.exists(file.path(devd_run_dir, "devd"))) {
    message("devd installed successfully")
  } else {
    warning("Error installing devd")
  }

}

#' Remove all sysetm traces of `devd` installed/created by this package
#'
#' "Leave no trace"
#'
#' @md
#' @export
remove_devd <- function() {

  devd_run_dir <- app_dir("rdevd")$config()
  devd_log_dir <- app_dir("rdevd")$log()

  invisible(suppressMessages(suppressWarnings(unlink(devd_run_dir, TRUE, TRUE))))
  invisible(suppressMessages(suppressWarnings(unlink(devd_log_dir, TRUE, TRUE))))

}
