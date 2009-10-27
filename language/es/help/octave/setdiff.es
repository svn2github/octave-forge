md5="b550a39526dcf4452664d5518bef9c9b";rev="6405";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} setdiff (@var{a}, @var{b})
@deftypefnx {Archivo de funci@'on} {} setdiff (@var{a}, @var{b}, "rows")
Retorna los elementos en @var{a} que no est@'an en @var{b}, organizados 
en orden ascendente. Si @var{a} y @var{b} son vectores columna, 
retorna un vector columa, en otro caso retorna un vector fila. 

Si se suministra el tercer argumento opcional @samp{"rows"}, retorna 
las filas en @var{a} que no est@'an en @var{b}, organizadas en orden 
ascendente por filas.
@seealso{unique, union, intersect, setxor, ismember}
@end deftypefn
