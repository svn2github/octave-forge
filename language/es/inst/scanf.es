md5="537e0d9fe70901a48207f48dd7edc39f";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {[@var{val}, @var{count}] =} scanf (@var{template}, @var{size})
@deftypefnx {Función incorporada} {[@var{v1}, @var{v2}, @dots{}, @var{count}]] = } scanf (@var{template}, "C")
Esta función es equivalente a llamar @code{fscanf} con @var{fid} = 
@code{stdin}.

Actualmente no es útil llamar @code{scanf} en programas interactivos.
@seealso{fscanf, sscanf, printf}
@end deftypefn
