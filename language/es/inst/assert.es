md5="ab53c205e71c22d4ef76b87965442044";rev="7201";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci�n} {} assert (@var{cond})
@deftypefnx {Archivo de funci�n} {} assert (@var{observed},@var{expected})
@deftypefnx {Archivo de funci�n} {} assert (@var{observed},@var{expected},@var{tol})

Produce un error si la condici�n no es cumplida. @code{assert} puede ser 
llamado en tres formas diferentes.

@table @code
@item assert (@var{cond})
Llamado con un �nico agumento @var{cond}, @code{assert} produce un
error si @var{cond} es cero.

@item assert (@var{observed}, @var{expected})
Produce un error si el valor @var{observed} no es el mismo que @var{expected}. N�tese que los 
valores @var{observed} y @var{expected} pueden ser cadenas de caracteres, escalares, vectores, matrices, 
listas o estructuras.

@item assert(@var{observed}, @var{expected}, @var{tol})
Acepta una tolerancia cuando compara n�meros. 
Si @var{tol} es positivo, usado como una tolerancia absoluta, producir� un error si
@code{abs(@var{observed} - @var{expected}) > abs(@var{tol})}.
Si @var{tol} es negativo, usado como una tolerancia relativa, producir� un error si
@code{abs(@var{observed} - @var{expected}) > abs(@var{tol} * @var{expected})}.
Si @var{expected} es cero, @var{tol} ser� siempre usado como tolerancia obsoluta.
@end table
@seealso{test}
@end deftypefn
