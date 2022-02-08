#' rgba_to_raster
#'
#' Create raster from given rgba matrix.
#'
#' @param rgba Integer rgba matrix (`red`, `green`, `blue` and `alpha` channels, dimension nxmx4).
#'
#' @return Raster result.
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
#' @importFrom grDevices as.raster
rgba_to_raster <- function(rgba)
{
    dim_rgba <- 4
    if((!is.matrix(rgba) && !is.array(rgba)) || dim(rgba)[3] != dim_rgba) stop('not supported matrix format')
    
    return(grDevices::as.raster(rgba, max = 255))
}
