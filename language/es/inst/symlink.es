md5="fbe0b21ba7df607222646d857f4342ff";rev="6287";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {[@var{err}, @var{msg}] =} symlink (@var{old}, @var{new})
Crea un enlace simb@'olico @var{new} el cual contiene la cadena 
@var{old}.

Si la ejecuci@'on es exitosa, @var{err} es 0 y @var{msg} es una 
cadena vacia. En otro caso, @var{err} es distinto de cero y 
@var{msg} contiene un mensaje de error dependiente del sistema. 
@seealso{link, readlink}
@end deftypefn
