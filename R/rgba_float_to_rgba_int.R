#' rgba_float_to_rgba_int
#'
#' Convert RGBA float matrix to RGBA integer matrix.
#'
#' @param fRGBA Float RGBA matrix (`red`, `green`, `blue` and `alpha` channels, dimension nxmx4, values ~ 0-1).
#'
#' @return Integer RGBA matrix (values ~ 0-255).
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
rgba_float_to_rgba_int <- function(fRGBA)
{
    dim_RGBA <- 4
    if((!is.matrix(fRGBA) && !is.array(fRGBA)) || dim(fRGBA)[3] != dim_RGBA) stop('not supported matrix format')
    
    rows <- dim(fRGBA)[1]
    cols <- dim(fRGBA)[2]
    
    i32RGBA <- array(as.integer(fRGBA*255), c(rows, cols, dim_RGBA))
    return(i32RGBA)
}
