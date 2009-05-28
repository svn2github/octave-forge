md5="9c88c237f803c851a596aba95109d560";rev="5875";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deffn {Comando} clear [-x] pattern @dots{}
Elimina los nombres que coinciden con los patrones de la tabla de 
s@'imbolos. El patr@'on puede contener los siguientes caracteres 
especiales:

@table @code
@item ?
Coincide con cualquier caracter sencillo.

@item *
Coincide con cero o mas caracteres.

@item [ @var{list} ]
Coincide con la lista de caracteres especificados por @var{list}. Si el 
primer caracter character es @code{!} o @code{^}, coincide con todos los 
caracteres excepto aquellos especificados por @var{list}. Por ejemplo, 
el patr@'on @samp{[a-zA-Z]} coincidir@'a con todos caracteres 
alfab@'eticos may@'usculas y min@'usculas.
@end table

Por ejemplo, el comando

@example
clear foo b*r
@end example

@noindent
limpia el nombre @code{foo} y todos los nombres que inician con la letra 
@code{b} y finalizan con la letra @code{r}.

Si @code{clear} se invoca sin argumentos, todas las variables definidas 
por el usuario (locales y globales) se limpian de la tabla de 
s@'imbolos. Si @code{clear} se invoca con por lo menos un argumento, 
solo los nombres visibles que coinciden con los argumentos se eliminan. 
Por ejemplo, suponga que define una funci@'on @code{foo}, y luego se oculta mediante la asignaci@'on @code{foo = 2}. Ejecutando el comando 
@kbd{clear foo} una vez, limpiar@'a la definici@'on de la variable y 
restaura la definici@'on de @code{foo} como una funci@'on. Ejecutando  
@kbd{clear foo} por segunda vez, limpiar@'a la definici@'on de la 
funci@'on.

Si se pasa el argumento -x, limpia las variables que no coinciden con 
los patrones.

Este comando no debe usarse dentro del cuerpo de una funci@'on.
@end deffn
