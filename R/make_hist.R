#' library(scattermore)
#' @export
make_hist <- function(
  xy,
  size = c(512, 512))
{
   n <- dim(xy)[1]
   if(dim(xy)[2] != 2) stop('2-column xy input expected')
   
   matrix <- rep(0, size[1] * size[2])
   
   result <- .C("hist_int",
     n = as.integer(n),
     size = as.integer(size),
     matrix = as.integer(matrix),
     xy = as.single(xy))
     
}
