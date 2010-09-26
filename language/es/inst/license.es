-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} license
Mostrar la licencia de Octave.

@deftypefnx {Archivo de funci@'on} {} license ("inuse")
Mostrar una lista de los paquetes que actualmente se está utilizando.

@deftypefnx {Archivo de funci@'on} {@var{retval} =} license ("inuse")
Devuelve una estructura que contiene los campos @code{feature} and
@code{user}.


@deftypefnx {Archivo de funci@'on} {@var{retval} =} license ("test", @var{feature})
Devuelve 1 si existe una licencia para el producto identificado por la cadena
@var{feature} y 0 en caso contrario. El argumento  @var{feature} tiene en cuenta
mayúsculas y sólo los primeros 27 caracteres son revisadas.

@deftypefnx {Archivo de funci@'on} {} license ("test", @var{feature}, @var{toggle})
prueba de licencia para activar o desactivar  @var{feature}, en función de
@var{toggle}, que puede ser uno de:

@table @samp
@item "enable"
Futuras pruebas para la licencia específica de @var{feature} se llevan a cabo
como de costumbre.
@item "disable"
Futuras pruebas para la licencia específica de @var{feature} devuelve 0.
@end table

@deftypefnx {Archivo de funci@'on} {@var{retval} =} license ("checkout", @var{feature})
Echa un vistazo a una licencia para @var{feature}, devolver 1 en caso de éxito y 0
en caso de fallo.

Esta función se proporciona por compatibilidad con with @sc{Matlab}.
@seealso{ver, version}
@end deftypefn
