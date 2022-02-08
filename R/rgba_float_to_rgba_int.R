#' rgba_float_to_rgba_int
#'
#' Convert rgba float matrix to rgba integer matrix.
#'
#' @param rgba Float rgba matrix (`red`, `green`, `blue` and `alpha` channels, dimension nxmx4, values ~ 0-1).
#'
#' @return Integer rgba matrix (values ~ 0-255).
#'
#' @export
#' @useDynLib scattermore2, .registration=TRUE
rgba_float_to_rgba_int <- function(rgba)
{
    dim_rgba <- 4
    if((!is.matrix(rgba) && !is.array(rgba)) || dim(rgba)[3] != dim_rgba) stop('not supported matrix format')
    
    rows <- dim(rgba)[1]
    cols <- dim(rgba)[2]
    
    rgba <- array(as.integer(rgba*255), c(rows, cols, dim_rgba))
    return(rgba)
}
