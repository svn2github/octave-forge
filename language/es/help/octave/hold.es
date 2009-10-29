md5="602317631a203d991c469062cf144437";rev="6408";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} hold @var{args}
Mantiene los datos actuales en la gr@'afica cuando se ejecutan subsecuentes 
comandos de graficaci@'on. Este comando permite ejecutar una serie de comandos 
de graficaci@'on y tener todos los resultados en la misma figura. El 
comportamiento predetermiando para cada gr@'afica nueva es limpiar el 
dispositivo de graficaci@'on inicial. Por ejemplo, el comando

@example
hold on
@end example

@noindent
activa el estado que mantine el resultado de la gr@'afica anterior en la 
figura actual. El argumento @code{"off"} desactiva esta propiedad, y 
@code{hold} sin argumentos intercambia el estado actual del comando.
@end deftypefn
