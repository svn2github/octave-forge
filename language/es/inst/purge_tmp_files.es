md5="1fc7f96153171eaf96d302bbf927463a";rev="6346";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {} purge_tmp_files
Elimina los archivos temporales creados por los comandos de graficaci@'on.

Octave crea archivos temporales para @code{gnuplot} y luego envia los 
comandos a @code{gnuplot} a trav@'es de un segmento. Octave eliminar@'a los 
archivos temporales al salir, pero si se est@'an realizando muchas gr@'aficas 
es probable que se quieran eliminar en medio de la sesi@'on.

@strong{Esta funci@'on es obsoleta y ser@'a removida en las futuras versiones 
de Octave.}
@end deftypefn
