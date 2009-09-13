md5="766ec8d2b64e5b09d5315313d3c8ea95";rev="6241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deffn {Comando} edit_history options
Si se invoca sin argumentos, @code{edit_history} permite editar la 
lista del historial usando el editor indicado en la varible @code{EDITOR}. Los 
comandos a ser editados se copian primero en un archivo temporal. Cuando sale 
del editor, Octave ejecuta los comandos que permanencen en el archivo. 
Frecuentemente es m@'as conveniente usar @code{edit_history} para definir las 
funciones  en lugar de intentar ingresarlos directamente en la l@'inea de comandos. 
En forma perdetermianda, el bloque de comandos se ejecuta tan pronto como se sale del 
editor. Para evitar la ejecuci@'on de cualquier comando, simplemente elimine todas las l@'ineas 
del b@'ufer antes de ejecutar el editor.

El comando @code{edit_history} toma dos argumentos opcionales especifincando 
los n@'umeros de los comandos en el historial  que van a ser editados. Por ejemplo, 
el comando 

@example
edit_history 13
@end example

@noindent
extrae todos los comandos desde el comando n@'umero 13 hasta el @'ultimo en el historial.
El comando 

@example
edit_history 13 169
@end example

@noindent
solo extrea los comandos 13 al 169. Si se especifica un n@'umero mayor como primer 
argumento, se revierte la lista de comandos antes de ponerlos en el b@'ufer para 
ser editados. Si se omiten los dos argumentos, se usa el @'ultimo comando en el 
historial.
@end deffn
