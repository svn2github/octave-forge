md5="1e1cdbf8962953ab3078c9fcd7efdd12";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{vi} =} griddata3 (@var{x}, @var{y}, @var{z}, @var{v} @var{xi}, @var{yi}, @var{zi}, @var{method}, @var{options})
Genera una malla regular a partir de datos irregulares mediante 
interpolación. 

La función se define como @code{@var{y} = f (@var{x},@var{y},@var{z})}.
Los puntos de interpolación son todos @var{xi}.

El método de interpolación puede ser @code{"nearest"} o @code{"linear"}. 
Si se omite el método, se usa el valor predetermiando @code{"linear"}.
@seealso{griddata, delaunayn}
@end deftypefn
