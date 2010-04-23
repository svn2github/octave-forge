md5="badaeef9e7b687603ce885414a7963e8";rev="7228";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {@var{val} =} echo_executing_commands ()
@deftypefnx {Función incorporada} {@var{old_val} =} echo_executing_commands (@var{new_val})
Consulta o establece la variable interna que controla el estado del comando @code{echo}.
Puede ser la suma de los siguentes valores: 

@table @asis
@item 1
Muestra los comandos leidos desde los scripts.

@item 2
Muestra los comandos de las funciones. 

@item 4
Muestra los comandos leidos desde la línea de comandos. 
@end table

Más de un estado puede estar activo a la vez. Por ejemplo, el valor de 3 es 
equivalente al comando @kbd{echo on all}.

El valor de @code{echo_executing_commands} se establece mediante el comando @kbd{echo} 
y la opcio@'n @code{--echo-input}.
@end deftypefn
