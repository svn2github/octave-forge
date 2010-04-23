md5="602317631a203d991c469062cf144437";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} hold @var{args}
Mantiene los datos actuales en la gráfica cuando se ejecutan subsecuentes 
comandos de graficación. Este comando permite ejecutar una serie de comandos 
de graficación y tener todos los resultados en la misma figura. El 
comportamiento predetermiando para cada gráfica nueva es limpiar el 
dispositivo de graficación inicial. Por ejemplo, el comando

@example
hold on
@end example

@noindent
activa el estado que mantine el resultado de la gráfica anterior en la 
figura actual. El argumento @code{"off"} desactiva esta propiedad, y 
@code{hold} sin argumentos intercambia el estado actual del comando.
@end deftypefn
