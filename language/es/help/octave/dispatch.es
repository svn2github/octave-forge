md5="8c7896a86388fa995004de6b1504634d";rev="6224";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {} dispatch (@var{f}, @var{r}, @var{type})
Reemplaza la funci@'on @var{f} con un despacho tal que la funci@'on @var{r}
es llamada cuando @var{f} es llamada con el primer argumento de tipo 
@var{type}. Si el tipo es @var{any}, llama @var{r} si ning@'un otro tipo 
coincide. La funci@'on original @var{f} es accesible usando 
@code{builtin (@var{f}, @dots{})}.

Si se omite @var{r}, limpia el despacho asociado con el tipo @var{type}.

Si se omiten @var{r} y @var{type}, lista los despachos de funciones 
para @var{f}.
@seealso{builtin}
@end deftypefn
