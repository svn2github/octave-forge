md5="537e0d9fe70901a48207f48dd7edc39f";rev="6300";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {[@var{val}, @var{count}] =} scanf (@var{template}, @var{size})
@deftypefnx {Funci@'on incorporada} {[@var{v1}, @var{v2}, @dots{}, @var{count}]] = } scanf (@var{template}, "C")
Esta funci@'on es equivalente a llamar @code{fscanf} con @var{fid} = 
@code{stdin}.

Actualmente no es @'util llamar @code{scanf} en programas interactivos.
@seealso{fscanf, sscanf, printf}
@end deftypefn
