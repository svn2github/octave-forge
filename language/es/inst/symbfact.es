-*- texinfo -*-
@deftypefn {Funci@'on cargable} {[@var{count}, @var{h}, @var{parent}, @var{post}, @var{r}]} = symbfact (@var{s}, @var{typ}, @var{mode})

Realiza un an�lisis de la factorizaci�n simb�lica en la matriz dispersa
@var{s}.
Donde

@table @asis
@item @var{s}
@var{s} es una compleja o real matriz dispersa.

@item @var{typ}
Es el tipo de la factorizaci�n y puede ser uno de los

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
El valor predeterminado es devolver la factorizaci�n de Cholesky para
@var{r}, y si @var{mode} is 'L', la transpuesta conjugada de la 
factorizaci�n de Choleksy se devuelve. La versi�n transpuesta conjugada
es m�s r�pida y usa menos memoria, pero devuelve los mismos valores para
las salidas @var{count}, @var{h}, @var{parent} y @var{post}.
@end table

Las variables de salida son

@table @asis
@item @var{count}
La fila de contadores de la factorizaci�n de Cholesky seg�n lo
determinado por @var{typ}.

@item @var{h}
La altura del �rbol de la eliminaci�n.

@item @var{parent}
El �rbol de la eliminaci�n en s�.

@item @var{post}
Una booleana matriz dispersa, cuya estructura es la de la factorizaci�n
de Cholesky seg�n lo determinado por  @var{typ}.
@end table
@end deftypefn
