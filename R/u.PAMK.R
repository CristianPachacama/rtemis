# u.PAMK.R
# ::rtemis::
# 2016 Efstathios D. Gennatas egenn.github.io

#' Partitioning Around Medoids with k Estimation
#'
#' Estimate PAM clustering solution and optimal k using \code{fpc::pamk}
#'
#' @inheritParams u.KMEANS
#' @inheritParams u.PAM
#' @param x Input matrix / data.frame
#' @param krange Integer vector: Range of k values to try
#' @param criterion Character: Criterion to use for selecting k: "asw", "multiasw" or "ch". See \code{fpc::pamk}
#' @param usepam Logical: If TRUE, use \code{cluster::pam}, otherwise use \code{cluster::clara}.
#' Default = TRUE
#' @param scaling Logical or Numeric vector: If TRUE, scale input. If numeric vector of length equal to number of
#' features, the features are divided by the corresponding value. Default = TRUE
#' @param diss Logical: If TRUE, treat \code{x} as a dissimilarity matrix, otherwise as a matrix of
#' cases by features. Default = TRUE, if x inherits from class \code{dist}, FALSE otherwise.
#' @param metric Character: Dissimilarity metric to be used. Options: 'euclidean', 'manhattan'
#' @param trace Integer [0, 3]: Trace level for \code{fpc::pamk}
#' @param ... Additional parameters to be passed to \code{fpc::pamk} and/or \code{cluster::pam}
#' @author Efstathios D. Gennatas
#' @return \link{rtClust} object
#' @family Clustering
#' @export

u.PAMK <- function(x,
                   krange = 2:10,
                   criterion = "asw",
                   usepam = ifelse(nrow(x) < 2000, TRUE, FALSE),
                   scaling = TRUE,
                   diss = inherits(data, "dist"),
                   metric = 'euclidean',
                   do.swap = TRUE,
                   trace = 0,
                   verbose = TRUE, ...) {

  # [ INTRO ] ====
  start.time <- intro(verbose = verbose)
  clust.name <- "PAMK"

  # [ DATA ] ====
  if (is.null(colnames(x))) colnames(x) <- paste0("Feature_", seq(NCOL(x)))
  x <- as.data.frame(x)
  xnames <- colnames(x)

  # [ DEPENDENCIES ] ====
  if (!depCheck("fpc", verbose = FALSE)) {
    cat("\n"); stop("Please install dependencies and try again")
  }

  # [ ARGUMENTS ] ====
  if (missing(x)) {
    print(args(u.PAMK))
    stop("x is missing")
  }

  # [ PAMK ] ====
  if (verbose) msg("Partitioning Around Medoids...")
  clust <- fpc::pamk(x,
                     krange = krange,
                     criterion = criterion,
                     usepam = usepam,
                     scaling = scaling,
                     diss = diss,
                     metric = metric,
                     do.swap = do.swap,
                     trace.lev = trace, ...)
  if (verbose) msg("Estimated optimal number of clusters:", clust$nc)

  # [ CLUSTERS ] ====
  clusters.train <- clust$pamobject$clustering

  # [ OUTRO ] ====
  extra <- list(bestk = clust$nc)
  cl <- rtClust$new(clust.name = clust.name,
                    k = length(unique(clusters.train)),
                    xnames = xnames,
                    clust = clust,
                    clusters.train = clusters.train,
                    clusters.test = NULL,
                    parameters = list(krange = krange,
                                      criterion = criterion,
                                      usepam = usepam,
                                      scaling = scaling,
                                      diss = diss,
                                      metric = metric,
                                      do.swap = do.swap),
                    extra = extra)
  outro(start.time, verbose = verbose)
  cl

} # rtemis::u.PAMK
