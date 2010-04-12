md5="a549f414f41276fc4405b6c3addf968f";rev="6377";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} intersect (@var{a}, @var{b})
@deftypefnx {Archivo de funci@'on} {[@var{c}, @var{ia}, @var{ib}] =} intersect (@var{a}, @var{b})
Retorna los elementos en @var{a} y @var{b}, ordenados en orden 
ascendente. Si @var{a} y @var{b} son vectores columna, retorna un
vector columna, en otro caso, retorna un vector fila.

Retorna los @'indices de los vectores @var{ia} y @var{ib} tal que 
@code{a(ia)==c} y @code{b(ib)==c}.
@end deftypefn
@seealso{unique, union, setxor, setdiff, ismember}
