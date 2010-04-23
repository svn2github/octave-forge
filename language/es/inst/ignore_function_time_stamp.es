md5="14b4ab05e00d35b2ed6a04bb1d1d1384";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {@var{val} =} ignore_function_time_stamp ()
@deftypefnx {Función incorporada} {@var{old_val} =} ignore_function_time_stamp (@var{new_val})
Consulta o establece la variable interna que controla si Octave chequea 
el tiempo marcado en los archivos cada vez que mira las funciones 
definidas en los archivos de la función. Si la variable interna se 
establece @code{"system"}, Octave no volverá a compilar automáticamente
los archivos de la función de los subdirectorios  
@file{@var{octave-home}/lib/@var{version}} si han cambiado desde que se compiló
por última vez, pero volverá a compilar los archivos de otra función en la
ruta de búsqueda si cambian. Si se establece a @code{"all"}, Octave no
volverá a compilar los archivos de la función a menos que sus definiciones
se eliminen con @code{clear}. Si se establece como "none", Octave siempre 
comprobará las marcas de tiempo en los archivos para determinar si las funciones
definidas en los archivos de función necesitan volver a compilarse.
@end deftypefn 