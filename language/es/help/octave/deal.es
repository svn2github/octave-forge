md5="fb7776437d38ea1e2783ecb3caa84eac";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{r1}, @var{r2}, @dots{}, @var{rn}] =} deal (@var{a})
@deftypefnx {Archivo de funci@'on} {[@var{r1}, @var{r2}, @dots{}, @var{rn}] =} deal (@var{a1}, @var{a2}, @dots{}, @var{an})

Copia los par@'ametros de entrada en los par@'ametros de salida correspondientes.
Si solo se suministra un par@'ametro de entrada, se copia su valor en cada salida.

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
