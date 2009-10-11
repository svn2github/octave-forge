md5="49538f1d3e24f2b549df1d55b20ebc1f";rev="6301";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {[@var{result}, @var{err}, @var{msg}] =} readlink (@var{symlink})
Lee el valor del enlace simb@'olico @var{symlink}. 

Si el resultado es exitoso, la variable @var{result} contiene el contenido 
del enlace simb@'olico @var{symlink}, @var{err} es 0 y @var{msg} es una 
cadena vacia. En otro caso, @var{err} es distinto de cero y @var{msg} 
continen un mensaje de error dependiente del sistema.
@seealso{link, symlink}
@end deftypefn
