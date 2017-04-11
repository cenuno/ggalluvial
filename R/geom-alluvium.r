#' Alluvia
#' 
#' \code{geom_alluvium} receives a dataset of the horizontal (\code{x}) and 
#' vertical (\code{y}, \code{ymin}, \code{ymax}) positions of the \strong{lodes}
#' of an alluvial diagram, the intersections of the alluvia with the strata.
#' It plots both the lodes themselves, using \code{\link{geom_lode}}, and the
#' flows between them, using \code{\link{geom_flow}}.
#' 
#' @section Aesthetics:
#' \code{geom_alluvium} understands the following aesthetics
#'   (required aesthetics are in bold):
#' \itemize{
#'   \item \strong{\code{x}}
#'   \item \strong{\code{y}}
#'   \item \strong{\code{ymin}}
#'   \item \strong{\code{ymax}}
#'   \item \code{alpha}
#'   \item \code{colour}
#'   \item \code{fill}
#'   \item \code{linetype}
#'   \item \code{size}
#'   \item \code{group}
#' }
#' Currently, \code{group} is ignored.
#' 
#' @name geom-alluvium
#' @import ggplot2
#' @seealso \code{\link[ggplot2]{layer}} for additional arguments,
#'   \code{\link{stat_stratum}} and \code{\link{geom_stratum}} for 
#'   intra-axis boxes, and
#'   \code{\link{ggalluvial}} for a shortcut method.
#' @inheritParams geom-lode
#' @param knot.pos The horizontal distance between a stratum (\code{width/2}
#'   from its axis) and the knot of the x-spline, as a proportion of the
#'   separation between strata. Defaults to 1/6.
#' @param ribbon_bend Deprecated; alias for \code{knot.pos}.
#' @example inst/examples/ex-geom-alluvium.r
#' @usage NULL
#' @export
geom_alluvium <- function(mapping = NULL,
                      data = NULL,
                      stat = "alluvium",
                      width = 1/3, axis_width = NULL,
                      knot.pos = 1/6, ribbon_bend = NULL,
                      na.rm = FALSE,
                      show.legend = NA,
                      inherit.aes = TRUE,
                      ...) {
  layer(
    geom = GeomAlluvium,
    mapping = mapping,
    data = data,
    stat = stat,
    position = "identity",
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      width = width, axis_width = axis_width,
      knot.pos = knot.pos, ribbon_bend = ribbon_bend,
      na.rm = na.rm,
      ...
    )
  )
}

#' @rdname geom-alluvium
#' @usage NULL
#' @export
GeomAlluvium <- ggproto(
  "GeomAlluvium", Geom,
  
  default_aes = aes(size = .5, linetype = 1,
                    colour = 0, fill = "gray", alpha = .5),
  
  setup_params = function(data, params) {
    
    if (!is.null(params$axis_width)) {
      warning("Parameter 'axis_width' is deprecated; use 'width' instead.")
      params$width <- params$axis_width
      params$axis_width <- NULL
    }
    
    if (!is.null(params$ribbon_bend)) {
      warning("Parameter 'ribbon_bend' is deprecated; use 'knot.pos' instead.")
      params$knot.pos <- params$ribbon_bend
      params$ribbon_bend <- NULL
    }
    
    params
  },
  
  setup_data = function(data, params) {
    
    # positioning parameters
    transform(data,
              knot.pos = params$knot.pos)
  },
  
  draw_group = function(self, data, panel_scales, coord,
                        width = 1/3, axis_width = NULL,
                        knot.pos = 1/6, ribbon_bend = NULL) {
    
    # add width to data
    data <- transform(data, width = width)
    
    first_row <- data[1, setdiff(names(data),
                                 c("x", "xmin", "xmax", "width",
                                   "y", "ymin", "ymax", "weight",
                                   "knot.pos")),
                      drop = FALSE]
    rownames(first_row) <- NULL
    
    if (nrow(data) == 1) {
      # spline coordinates (one axis)
      spline_data <- data.frame(
        x = data$x + data$width / 2 * c(-1, 1, 1, -1),
        y = data$ymin + first_row$weight * c(0, 0, 1, 1),
        shape = rep(0, 4)
      )
    } else {
      # spline coordinates (more than one axis)
      spline_data <- data_to_xspl(data)
    }
    data <- data.frame(first_row, spline_data)
    
    # transform (after calculating spline paths)
    coords <- coord$transform(data, panel_scales)
    
    # graphics object
    grid::xsplineGrob(
      x = coords$x, y = coords$y, shape = coords$shape,
      open = FALSE,
      gp = grid::gpar(
        col = coords$colour, fill = coords$fill, alpha = coords$alpha,
        lty = coords$linetype, lwd = coords$size * .pt
      )
    )
  },
  
  draw_key = draw_key_polygon
)

# x-spline coordinates from data
data_to_xspl <- function(data) {
  w_oneway <- rep(data$width, c(3, rep(4, nrow(data) - 2), 3))
  k_oneway <- rep(data$knot.pos, c(3, rep(4, nrow(data) - 2), 3))
  x_oneway <- rep(data$x, c(3, rep(4, nrow(data) - 2), 3)) +
    w_oneway / 2 * c(-1, rep(c(1, 1, -1, -1), nrow(data) - 1), 1) +
    k_oneway * (1 - w_oneway) * c(0, rep(c(0, 1, -1, 0), nrow(data) - 1), 0)
  ymin_oneway <- rep(data$ymin, c(3, rep(4, nrow(data) - 2), 3))
  ymax_oneway <- rep(data$ymax, c(3, rep(4, nrow(data) - 2), 3))
  shape_oneway <- c(0, rep(c(0, 1, 1, 0), nrow(data) - 1), 0)
  data.frame(
    x = c(x_oneway, rev(x_oneway)),
    y = c(ymin_oneway, rev(ymax_oneway)),
    shape = rep(shape_oneway, 2)
  )
}
