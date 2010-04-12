md5="dde8fd021a8ab0d24a6cba89885f0a98";rev="6287";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {[@var{err}, @var{msg}] =} mkfifo (@var{name}, @var{mode})
Crea un archivo especial @var{fifo} llamado @var{name} con el modo 
de archivo @var{mode}.

Si la ejecuci@'on es exitosa, @var{err} es 0 y @var{msg} es una cadena 
vacia. En otro caso, @var{err} es distinto de cero y @var{msg} contiene 
un mensaje de error dependiente del sistema. 
@end deftypefn
