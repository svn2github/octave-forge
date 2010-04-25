md5="c505247047211a9c33be1b94559b3289";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} stairs (@var{x}, @var{y})
Produce una gráfica escalonada. Los argumentos pueden ser vectores 
o matrices.

Si solo se suministra un argumento, se toma como los valores de @code{y} 
y las coordenadas @code{x} se toman a partir de los índices de los 
elementos.

Si se suministran dos argumentos de salida, genera los datos pero no se 
grafican. Por ejemplo, 

@example
stairs (x, y);
@end example

@noindent
y 

@example
@group
[xs, ys] = stairs (x, y);
plot (xs, ys);
@end group
@end example

@noindent
son equivalentes.

@seealso{plot, semilogx, semilogy, loglog, polar, mesh, contour,
bar, xlabel, ylabel, title}
@end deftypefn
