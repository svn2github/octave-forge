-*- texinfo -*-
@deffn {Comando} lookfor @var{str}
@deffnx {Comando} lookfor -all @var{str}
@deffnx {Function} {[@var{fun}, @var{helpstring}] = } lookfor (@var{str})
@deffnx {Function} {[@var{fun}, @var{helpstring}] = } lookfor ('-all', @var{str})
Busqueda para la cadena @var{str} en todas las funciones que se 
encuentran en la ruta de búsqueda de función. De forma predeterminada
@code{lookfor} busca para @var{str} en la primera frase de la cadena
de ayuda de cada función encontrada. La cadena de ayuda completa de cada
función encontrada en la ruta puede ser buscada si el argumento '-all' es 
suministrado. Todas las búsquedas son sensibles a mayúsculas.

la llamada sin argumentos de salida, @code{lookfor} muestra la lista 
de funciones de coincidencia a la terminal. De lo contrario los 
argumentos de salida @var{fun} y @var{helpstring} definen las funciones
coincidentes y la primera frase de cada una de las cadenas de su ayuda.

Tenga en cuenta que la capacidad de @code{lookfor} para identificar 
correctamente la primera frase de la ayuda de las funciones depende
del formato de las funciones de ayuda. Todas las funciones en Octave
se encontrarán correctamente la primera frase, pero por lo mismo no
puede ser garantizada para otras funciones. Por lo tanto el uso del
argumento '-all'  podría ser necesario para encontrar las funciones
relacionadas que no forman parte de Octave.

@seealso{help, which}
@end deffn
