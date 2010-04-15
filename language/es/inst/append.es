md5="bf4d851335ad6e7a413419ae0a781b32";rev="7201";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Built-in Function} {} append (@var{list}, @var{a1}, @var{a2}, @dots{})
Retorna una lista nueva creada añadiendo @var{a1}, @var{a1}, @dots{}, a
@var{list}. Si alguno de los agumentos a ser añadido es una lista, sus
elementos son añadidos individualmente. Por ejemplo,

@example
x = list (1, 2);
y = list (3, 4);
append (x, y);
@end example

@noindent
retorna una lista conteniendo los cuatro elementos @samp{(1 2 3 4)}, en lugar 
de una lista con los tres elementos @samp{(1 2 (3 4))}.
@end deftypefn
