-*- texinfo -*-
@deftypefn {Funci@'on cargable} {[@var{count}, @var{h}, @var{parent}, @var{post}, @var{r}]} = symbfact (@var{s}, @var{typ}, @var{mode})

Realiza un análisis de la factorización simbólica en la matriz dispersa
@var{s}.
Donde

@table @asis
@item @var{s}
@var{s} es una compleja o real matriz dispersa.

@item @var{typ}
Es el tipo de la factorización y puede ser uno de los

@table @code
@item sym
Factorizar @var{s}. Este es el predeterminado.

@item col
Factorizar @code{@var{s}' * @var{s}}.
@item row
Factorizar @code{@var{s} * @var{s}'}.
@item lo
Factorizar @code{@var{s}'}
@end table

@item @var{mode}
El valor predeterminado es devolver la factorización de Cholesky para
@var{r}, y si @var{mode} is 'L', la transpuesta conjugada de la 
factorización de Choleksy se devuelve. La versión transpuesta conjugada
es más rápida y usa menos memoria, pero devuelve los mismos valores para
las salidas @var{count}, @var{h}, @var{parent} y @var{post}.
@end table

Las variables de salida son

@table @asis
@item @var{count}
La fila de contadores de la factorización de Cholesky según lo
determinado por @var{typ}.

@item @var{h}
La altura del árbol de la eliminación.

@item @var{parent}
El árbol de la eliminación en sí.

@item @var{post}
Una booleana matriz dispersa, cuya estructura es la de la factorización
de Cholesky según lo determinado por  @var{typ}.
@end table
@end deftypefn
