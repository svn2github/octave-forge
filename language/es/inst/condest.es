md5="ff544b55191f98c5ca05f06e3ba06fc1";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{est}, @var{v}] =} condest (@var{a}, @var{t}) 
@deftypefnx {Archivo de función} {[@var{est}, @var{v}] =} condest (@var{a}, @var{solve}, @var{solve_t}, @var{t})
@deftypefnx {Archivo de función} {[@var{est}, @var{v}] =} condest (@var{apply}, @var{apply_t}, @var{solve}, @var{solve_t}, @var{n}, @var{t})

Calcula el (norma-uno) número de condición de una matriz @var{A}
usando @var{t} vectores de prueba con un estimador de norm-uno aleatorio.
Si @var{t} es mayor que 5, solo se usan 5 vetores de prueba.

Si la matriz no es explícita, e.g. cuando se estima el número de 
condición de @var{a} dada una factorizyción LU, @code{condest} usa las
siguientes funciones:

@table @var
@item apply
@code{A*x} para una matriz @code{x} de tamaño @var{n} por @var{t}.
@item apply_t
@code{A'*x} para una matriz @code{x} de tamaño @var{n} por @var{t}.
@item solve
@code{A \ b} para una matriz @code{b} de tamaño @var{n} por @var{t}.
@item solve_t
@end deftypefn