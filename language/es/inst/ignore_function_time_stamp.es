md5="14b4ab05e00d35b2ed6a04bb1d1d1384";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {@var{val} =} ignore_function_time_stamp ()
@deftypefnx {Funci@'on incorporada} {@var{old_val} =} ignore_function_time_stamp (@var{new_val})
Consulta o establece la variable interna que controla si Octave chequea 
el tiempo marcado en los archivos cada vez que mira las funciones 
definidas en los archivos de la funci@'on. Si la variable interna se 
establece @code{"system"}, Octave no volver@'a a compilar autom@'aticamente
los archivos de la funci@'on de los subdirectorios  
@file{@var{octave-home}/lib/@var{version}} si han cambiado desde que se compil@'o
por @'ultima vez, pero volver@'a a compilar los archivos de otra funci@'on en la
ruta de b@'usqueda si cambian. Si se establece a @code{"all"}, Octave no
volver@'a a compilar los archivos de la funci@'on a menos que sus definiciones
se eliminen con @code{clear}. Si se establece como "none", Octave siempre 
comprobar@'a las marcas de tiempo en los archivos para determinar si las funciones
definidas en los archivos de funci@'on necesitan volver a compilarse.
@end deftypefn 