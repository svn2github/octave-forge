md5="27d593bf9284c548f32741e7e1a41523";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} hadamard (@var{n})
Construir una matriz de Hadamard @var{Hn} de tama@~{n}o @var{n}-por-@var{n}.
El tama@~{n}o de @var{n} debe ser de la forma @code{2 ^ @var{k} * @var{p}} 
en el que @var{p} es uno de 1, 12, 20 o 28. La matriz devuelta es 
normalizada, significando @code{Hn(:,1) == 1} y @code{H(1,:) == 1}.

Algunas de las propiedades de las matrices de Hadamard son:

@itemize @bullet
@item
@code{kron (@var{Hm}, @var{Hn})} is a Hadamard matrix of size 
@var{m}-by-@var{n}.
@item
@code{Hn * Hn' == @var{n} * eye (@var{n})}.
@item
Las filas de @var{Hn} son ortogonales.
@item
@code{det (@var{A}) <= det (@var{Hn})} for all @var{A} with 
@code{abs (@var{A} (@var{i}, @var{j})) <= 1}.
@item
Multiplicar cualquier fila o columna por -1 y tendra todavía 
una matriz de Hadamard.
@end itemize

@end deftypefn