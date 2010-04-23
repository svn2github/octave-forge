md5="71ee89f2433011145e7460fbcfecdecb";rev="7228";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deffn {Comando} echo @var{options}
Controla si los comandos se muestran cuando se ejecutados. El valor de 
@{options} puede ser:

@table @code
@item on
Activa la impresión de comandos cuando son ejecutados en los scripts.

@item off
Desactiva la impresión de comandos cuando son ejecutados en los scripts.

@item on all
Activa la impresión de comandos cuando son ejecutados en scripts y 
funciones.

@item off all
Desactiva la impresión de comandos cuando son ejecutados en scripts y 
funciones.
@end table

@noindent
Si se invoca sin parámetros, @code{echo} intercambia su estado actual.
@end deffn
