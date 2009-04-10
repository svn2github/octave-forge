md5="ab53c205e71c22d4ef76b87965442044";rev="5693";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} assert (@var{cond})
@deftypefnx {Archivo de funci@'on} {} assert (@var{observed},@var{expected})
@deftypefnx {Archivo de funci@'on} {} assert (@var{observed},@var{expected},@var{tol})

Produce un error si la condici@'on no es cumplida. @code{assert} puede ser 
llamado en tres formas diferentes.

@table @code
@item assert (@var{cond})
Llamado con un @'unico agumento @var{cond}, @code{assert} produce un
error si @var{cond} es cero.

@item assert (@var{observed}, @var{expected})
Produce un error si el valor @var{observed} no es el mismo que @var{expected}. N@'otese que los 
valores @var{observed} y @var{expected} pueden ser cadenas de caracteres, escalares, vectores, matrices, 
listas o estructuras.

@item assert(@var{observed}, @var{expected}, @var{tol})
Acepta una tolerancia cuando compara n@'umeros. 
Si @var{tol} es positivo, usado como una tolerancia absoluta, producir@'a un error si
@code{abs(@var{observed} - @var{expected}) > abs(@var{tol})}.
Si @var{tol} es negativo, usado como una tolerancia relativa, producir@'a un error si
@code{abs(@var{observed} - @var{expected}) > abs(@var{tol} * @var{expected})}.
Si @var{expected} es cero, @var{tol} ser@'a siempre usado como tolerancia obsoluta.
@end table
@seealso{test}
@end deftypefn
