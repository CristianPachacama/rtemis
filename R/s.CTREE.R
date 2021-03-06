# s.CTREE.R
# ::rtemis::
# 2017 Efstathios D. Gennatas egenn.github.io

#' Conditional Inference Trees [C, R, S]
#'
#' Train a conditional inference tree using {partykit::ctree}
#'
#' @inheritParams s.GLM
#' @param control List of parameters for the CTREE algorithms. Set using
#' \code{partykit::ctree_control}
#' @return \link{rtMod} object
#' @author Efstathios D. Gennatas
#' @seealso \link{elevate}
#' @family Supervised Learning
#' @family Tree-based methods
#' @export

s.CTREE <- function(x, y = NULL,
                    x.test = NULL, y.test = NULL,
                    weights = NULL,
                    control = partykit::ctree_control(),
                    ipw = TRUE,
                    ipw.type = 2,
                    upsample = FALSE,
                    downsample = FALSE,
                    resample.seed = NULL,
                    x.name = NULL,
                    y.name = NULL,
                    print.plot = TRUE,
                    plot.fitted = NULL,
                    plot.predicted = NULL,
                    plot.theme = getOption("rt.fit.theme", "lightgrid"),
                    question = NULL,
                    verbose = TRUE,
                    outdir = NULL,
                    save.mod = ifelse(!is.null(outdir), TRUE, FALSE), ...) {

  # [ INTRO ] ====
  if (missing(x)) {
    print(args(s.CTREE))
    invisible(9)
  }
  if (!is.null(outdir)) outdir <- normalizePath(outdir, mustWork = FALSE)
  logFile <- if (!is.null(outdir)) {
    paste0(outdir, "/", sys.calls()[[1]][[1]], ".", format(Sys.time(), "%Y%m%d.%H%M%S"), ".log")
  } else {
    NULL
  }
  start.time <- intro(verbose = verbose, logFile = logFile)
  mod.name <- "CTREE"

  # [ DEPENDENCIES ] ====
  if (!depCheck("partykit", verbose = FALSE)) {
    cat("\n"); stop("Please install dependencies and try again")
  }

  # [ ARGUMENTS ] ====
  if (is.null(x.name)) x.name <- getName(x, "x")
  if (is.null(y.name)) y.name <- getName(y, "y")
  if (!verbose) print.plot <- FALSE
  verbose <- verbose | !is.null(logFile)
  if (save.mod & is.null(outdir)) outdir <- paste0("./s.", mod.name)
  if (!is.null(outdir)) outdir <- paste0(normalizePath(outdir, mustWork = FALSE), "/")

  # [ DATA ] ====
  dt <- dataPrepare(x, y, x.test, y.test,
                    ipw = ipw,
                    ipw.type = ipw.type,
                    upsample = upsample,
                    downsample = downsample,
                    resample.seed = resample.seed,
                    verbose = verbose)
  x <- dt$x
  y <- dt$y
  x.test <- dt$x.test
  y.test <- dt$y.test
  xnames <- dt$xnames
  type <- dt$type
  if (is.null(weights) & ipw) weights <- dt$weights
  if (verbose) dataSummary(x, y, x.test, y.test, type)
  if (print.plot) {
    if (is.null(plot.fitted)) plot.fitted <- if (is.null(y.test)) TRUE else FALSE
    if (is.null(plot.predicted)) plot.predicted <- if (!is.null(y.test)) TRUE else FALSE
  } else {
    plot.fitted <- plot.predicted <- FALSE
  }

  # [ FORMULA ] ====
  df.train <- data.frame(y = y, x)
  features <- paste(xnames, collapse = " + ")
  .formula <- as.formula(paste(y.name, "~", features))

  # [ CTREE ] ====
  if (verbose) msg("Training Conditional Inference Tree...", newline.pre = TRUE)
  # Instead of loading the whole package
  # because partykit::ctree does this:
  # mf[[1L]] <- quote(extree_data)
  # d <- eval(mf, parent.frame())
  extree_data <- partykit::extree_data
  mod <- partykit::ctree(formula = .formula,
                         data = df.train,
                         weights = weights,
                         control = control, ...)

  # [ FITTED ] ====
  if (type == "Classification") {
    fitted.prob <- predict(mod, x, type = "prob")
  }
  fitted <- predict(mod, x, type = "response")
  error.train <- modError(y, fitted)
  if (verbose) errorSummary(error.train, mod.name)

  # [ PREDICTED ] ====
  predicted.prob <- predicted <- error.test <- NULL
  if (!is.null(x.test)) {
    predicted.prob <- predict(mod, x.test, type = "prob")
    predicted <- predict(mod, x.test, type = "response")
    if (!is.null(y.test)) {
      error.test <- modError(y.test, predicted)
      if (verbose) errorSummary(error.test, mod.name)
    }
  }

  # [ OUTRO ] ====
  extra <- list(formula = .formula,
                weights = weights)
  if (type == "Classification") {
    extra$fitted.prob <- fitted.prob
    extra$predicted.prob <- predicted.prob
  }
  rt <- rtMod$new(mod.name = mod.name,
                  y.train = y,
                  y.test = y.test,
                  x.name = x.name,
                  xnames = xnames,
                  mod = mod,
                  type = type,
                  fitted = fitted,
                  se.fit = NULL,
                  error.train = error.train,
                  predicted = predicted,
                  se.prediction = NULL,
                  error.test = error.test,
                  question = question,
                  extra = extra)

  rtMod.out(rt,
            print.plot,
            plot.fitted,
            plot.predicted,
            y.test,
            mod.name,
            outdir,
            save.mod,
            verbose,
            plot.theme)

  outro(start.time, verbose = verbose, sinkOff = ifelse(is.null(logFile), FALSE, TRUE))
  rt

} # rtemis::s.CTREE
