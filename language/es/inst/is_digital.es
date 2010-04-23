md5="03ccc54506e8601db989c4a5cfd41a0f";rev="7231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{digital} =} is_digital (@var{sys}, @var{eflg})
Regresa distinto de cero si el sistema es digital.

@strong{Entradas}
@table @var
@item sys
Estructura de datos del sistema.
@item eflg
Cuando es igual a 0 (valor por defecto), sale con un error si el sistema
es mixto (componentes continuos y discretos); cuando es igual a 1, 
imprime una advertencia si el sistema es mixto (continuos y discretos);
cuando igual a 2, operan en silencio.
@end table

@strong{Output}
@table @var
@item digital
Cuando igual a 0, el sistema es puramente continuo; cuando igual 1, el 
sistema es puramente discreto; cuando es igual a -1, el sistema es mixto
continuo y discreto.
@end table
Sale con un error si @var{sys} es mixto sistema (continuo y discreto).
@end deftypefn