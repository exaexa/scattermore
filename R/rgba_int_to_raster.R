#' rgba_int_to_raster
#'
#' Create raster from given RGBA matrix.
#'
#' @param i32RGBA Integer RGBA matrix (`red`, `green`, `blue` and `alpha` channels, dimension nxmx4, values ~ 0-255).
#'
#' @return Raster result.
#'
#' @export
#' @useDynLib scattermore, .registration=TRUE
#' @importFrom grDevices as.raster
rgba_int_to_raster <- function(i32RGBA)
{
    dim_RGBA <- 4
    if(!is.array(i32RGBA) || dim(i32RGBA)[3] != dim_RGBA) stop('not supported i32RGBA format')
    
    return(grDevices::as.raster(i32RGBA, max = 255))
}
