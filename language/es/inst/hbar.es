md5="09e74375502ed03e198f5fa49be7c4e6";rev="7332";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{h} =} hbar (@var{x}, @var{y}, @var{style})
@deftypefnx {Archivo de función} {[@var{xb}, @var{yb}] =} hbar (@dots{})
Dados dos vectores de datos x-y, @code{bar} produce un gráfico de
barras horizontales.

Si se da solo un argumento, se toma como un vector de valores-y, y las
coordenadas x son tomadas de los índices de los elementos.

Si @var{y} es una matriz, cada columna de @var{y} se toma como un gráfico
de barras separadas representadas en la misma gráfica. Por defecto, las
columnas se representan de lado a lado. Este comportamiento puede ser 
modificado por el argumento @var{style}, que puede tomar el valor 'grupo' 
(por defecto), o 'stack'.

Si dos argumentos de salida son especificados, la información es 
generada pero no representada. por ejemplo,

@example
hbar (x, y);
@end example

@noindent
y

@example
[xb, yb] = hbar (x, y);
plot (xb, yb);
@end example

@noindent
son equivalentes.
@seealso{bar, plot, semilogx, semilogy, loglog, polar, mesh, contour,
stairs, xlabel, ylabel, title}
@end deftypefn 