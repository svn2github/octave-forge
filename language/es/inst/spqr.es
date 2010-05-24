md5="7f5044148e6f1ed0ef6d98400317fee9";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {@var{r} =} spqr (@var{a})
@deftypefnx {Función cargable} {@var{r} =} spqr (@var{a},0)
@deftypefnx {Función cargable} {[@var{c}, @var{r}] =} spqr (@var{a},@var{b})
@deftypefnx {Función cargable} {[@var{c}, @var{r}] =} spqr (@var{a},@var{b},0)
@cindex QR factorization
Calcular la factorización dispersa QR de @var{a}, usando @sc{CSparse}.
Como la matriz @var{Q} es en general una completa matriz, esta función 
devuelve el  @var{Q}-less factorización @var{r} de @var{a}, tal que 
@code{@var{r} = chol (@var{a}' * @var{a})}.

Si el argumento final es el escalar @code{0} y el número de filas es 
mayor que el número de columnas, entonces, una economíca factorización
devuelve. Eso es @var{r} sólo tendrá @code{size (@var{a},1)} filas.

Si una matriz adicional @var{b} se suministra, entonces, @code{spqr} 
devuelve @var{c}, where @code{@var{c} = @var{q}' * @var{b}}. Esto permite
que la aproximación por mínimos cuadrados de @code{@var{a} \ @var{b}} se
calcula como

@example
[@var{c},@var{r}] = spqr (@var{a},@var{b})
@var{x} = @var{r} \ @var{c}
@end example
@seealso{spchol, qr}
@end deftypefn
