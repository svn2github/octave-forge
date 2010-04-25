md5="1fc7f96153171eaf96d302bbf927463a";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {} purge_tmp_files
Elimina los archivos temporales creados por los comandos de graficación.

Octave crea archivos temporales para @code{gnuplot} y luego envia los 
comandos a @code{gnuplot} a través de un segmento. Octave eliminará los 
archivos temporales al salir, pero si se están realizando muchas gráficas 
es probable que se quieran eliminar en medio de la sesión.

@strong{Esta función es obsoleta y será removida en las futuras versiones 
de Octave.}
@end deftypefn
