md5="1e1cdbf8962953ab3078c9fcd7efdd12";rev="6381";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{vi} =} griddata3 (@var{x}, @var{y}, @var{z}, @var{v} @var{xi}, @var{yi}, @var{zi}, @var{method}, @var{options})
Genera una malla regular a partir de datos irregulares mediante 
interpolaci@'on. 

La funci@'on se define como @code{@var{y} = f (@var{x},@var{y},@var{z})}.
Los puntos de interpolaci@'on son todos @var{xi}.

El m@'etodo de interpolaci@'on puede ser @code{"nearest"} o @code{"linear"}. 
Si se omite el m@'etodo, se usa el valor predetermiando @code{"linear"}.
@seealso{griddata, delaunayn}
@end deftypefn
