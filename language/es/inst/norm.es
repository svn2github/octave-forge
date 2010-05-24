md5="074d77ba28d0f81b251df6e651c8fa05";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} norm (@var{a}, @var{p})
Calcule la norma-p de la matriz @var{a}. Si el segundo argumento
falta, se asume @code{p = 2}.

Si @var{a} es una matriz:

@table @asis
@item @var{p} = @code{1}
norma-1, la suma más grande de la columna de los valores absolutos
de @var{a}.

@item @var{p} = @code{2}
Mayor valor singular de @var{a}.

@item @var{p} = @code{Inf} or @code{"inf"}
@cindex infinity norm
Norma infinita, la suma más grande de la fila de los valores 
absolutos de@var{a}.

@item @var{p} = @code{"fro"}
@cindex Frobenius norm
Norma Frobenius de @var{a}, @code{sqrt (sum (diag (@var{a}' * @var{a})))}.
@end table

Si @var{a} es un vector o un escalar:

@table @asis
@item @var{p} = @code{Inf} or @code{"inf"}
@code{max (abs (@var{a}))}.

@item @var{p} = @code{-Inf}
@code{min (abs (@var{a}))}.

@item @var{p} = @code{"fro"}
Norma Frobenius de @var{a}, @code{sqrt (sumsq (abs (a)))}.

@item other
norma-p de @var{a}, @code{(sum (abs (@var{a}) .^ @var{p})) ^ (1/@var{p})}.
@end table
@seealso{cond, svd}
@end deftypefn 