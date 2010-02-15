md5="102d482009a67f10c1ea917f4609e48a";rev="6893";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} index (@var{s}, @var{t})
@deftypefnx {Archivo de funci@'on} {} index (@var{s}, @var{t}, @var{direction})
Regresa la posici@'on de la primera ocurrencia del string @var{t} en la 
string @var{s}, o cero si no encuentra una ocurrencia. Por ejemplo,

@example
index ("Teststring", "t")
@result{} 4
@end example

Si @var{direction} es @samp{"first"}, regresa el primer elemento encontrado.
Si @var{direction} es @samp{"last"}, regresa el ultimo elemento encontrado.
La funci@'on @code{rindex} es equivalente a @code{index} con
@var{direction} establecida como  @samp{"last"}.

@strong{Precauci@'on:} Esta funcion no se implementa para arreglos de cadenas
de caracteres.
@seealso{find, rindex}
@end deftypefn