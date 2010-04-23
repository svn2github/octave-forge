md5="fb7776437d38ea1e2783ecb3caa84eac";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{r1}, @var{r2}, @dots{}, @var{rn}] =} deal (@var{a})
@deftypefnx {Archivo de función} {[@var{r1}, @var{r2}, @dots{}, @var{rn}] =} deal (@var{a1}, @var{a2}, @dots{}, @var{an})

Copia los parámetros de entrada en los parámetros de salida correspondientes.
Si solo se suministra un parámetro de entrada, se copia su valor en cada salida.

Por ejemplo,

@example
[a, b, c] = deal (x, y, z);
@end example

@noindent
es equivalente a 

@example
@group
a = x;
b = y;
c = z;
@end group
@end example

@noindent
and

@example
[a, b, c] = deal (x);
@end example

@noindent
es equivalente a 

@example
a = b = c = x;
@end example
@end deftypefn
