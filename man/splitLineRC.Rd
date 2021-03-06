% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/addTreeLeaves.R
\name{splitLineRC}
\alias{splitLineRC}
\title{\code{rtemis} internal: Ridge and Stump}
\usage{
splitLineRC(
  g,
  type,
  node.index,
  alpha = 0,
  lambda = 0.01,
  lambda.seq = NULL,
  cv.glmnet.nfolds = 5,
  part.minsplit = 2,
  part.xval = 0,
  part.max.depth = 1,
  part.cp = 0,
  minobsinnode.lin = 5,
  lin.type = "glmnet",
  verbose = TRUE,
  trace = 0
)
}
\arguments{
\item{node.index}{Open nodes to work on

Fit a linear model on (x, y) and a tree on the residual y - yhat
Input: environment holding tree and inde of node
Output: None; Expands tree within env by splitting indexed node}

\item{tree}{Node within tree environment}
}
\description{
Edits environment 'g' in-place (no output)
}
