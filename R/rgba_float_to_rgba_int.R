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
    if(!is.array(fRGBA) || dim(fRGBA)[3] != dim_RGBA) stop('not supported fRGBA format')
    
    rows <- dim(fRGBA)[1]
    cols <- dim(fRGBA)[2]
    
    A <- fRGBA[,,4]
    R <- ifelse(A == 0, 0, fRGBA[,,1] / A)  #preventing zero division
    G <- ifelse(A == 0, 0, fRGBA[,,2] / A)  #"unpremultiply" alpha
    B <- ifelse(A == 0, 0, fRGBA[,,3] / A)
    
    fRGBA[,,1] <- R
    fRGBA[,,2] <- G
    fRGBA[,,3] <- B
    
    i32RGBA <- array(as.integer(fRGBA * 255), c(rows, cols, dim_RGBA))
    return(i32RGBA)
}
