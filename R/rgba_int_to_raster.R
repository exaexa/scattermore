#' rgba_int_to_raster
#'
#' Create raster from given rgba matrix.
#'
#' @param rgba Integer rgba matrix (`red`, `green`, `blue` and `alpha` channels, dimension nxmx4, values ~ 0-255).
#'
#' @return Raster result.
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
#' @importFrom grDevices as.raster
rgba_int_to_raster <- function(rgba)
{
    dim_rgba <- 4
    if((!is.matrix(rgba) && !is.array(rgba)) || dim(rgba)[3] != dim_rgba) stop('not supported matrix format')
    
    rows <- dim(rgba)[1]
    cols <- dim(rgba)[2]
    
    rgba <- array(as.integer(rgba), c(rows, cols, dim_rgba))
    return(grDevices::as.raster(rgba, max = 255))
}
