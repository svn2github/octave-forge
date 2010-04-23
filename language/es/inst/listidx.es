md5="0a6bb5134145c7fb17b00d6ebd639275";rev="7231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{idxvec}, @var{errmsg}] =} listidx (@var{listvar}, @var{strlist})
Regresa los índices de entradas de cadenas (string )en @var{listvar}
que deben coincidir con las cadenas en @var{strlist}.

Ambas @var{listvar} y @var{strlist} deben ser pasadas como cadenas
de caracteres(string) o matrices. Si son pasadas como matrices de 
cadenas, cada entrada es procesada por @code{deblank} previo a la 
búsqueda de las entradas.

La primera salida es el vector de índices en @var{listvar}.

Si @var{strlist} no contiene una cadena (string) en @var{listvar},
entonces un mensaje de error es regresado en @var{errmsg}. Si sólo
un argumento de salida es requerido, entonces @var{listidx} imprime
@var{errmsg} sobre la pantralla y sale con un error.
@end deftypefn
