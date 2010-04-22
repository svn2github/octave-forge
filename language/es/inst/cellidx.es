md5="718fb77fb01597310c3ca3b663bfad0f";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{idxvec}, @var{errmsg}] =} cellidx (@var{listvar}, @var{strlist})
Retorna los índices de las cadenas de entradas en @var{listvar} que 
coinciden con las cadenas en @var{strlist}.

Tanto @var{listvar} como @var{strlist} pueden ser pasados como cadenas 
o matrices de cadenas. Si son pasados como matrices de cadenas, cada entrada es procesada por @code{deblank} previo a buscar las entradas.

La primera salida es el vector de índices en @var{listvar}.

Si @var{strlist} no contiene una cadena en @var{listvar}, se retorna un 
mensaje de error en @var{errmsg}. Si solo un argumento salida se 
reuiere, @var{cellidx} imprime @var{errmsg} en la pantalla y termina su ejecución con un error.
@end deftypefn
