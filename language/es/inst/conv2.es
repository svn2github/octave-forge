md5="194ff68fcf189f779cc763af49dd2f56";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {y =} conv2 (@var{a}, @var{b}, @var{shape})
@deftypefnx {Funci@'on cargable} {y =} conv2 (@var{v1}, @var{v2}, @var{M}, @var{shape})

Retorna la convoluci@'on 2-D de @var{a} y @var{b} donde el tama@~{n}o 
de @var{c} est@'a dado por:

@table @asis
@item @var{shape}= 'full'
retorna convoluci@'on 2-D completa.
@item @var{shape}= 'same'
el mismo tama@~{n}o que @var{a}. Parte 'central' de la convoluci@'on.
@item @var{shape}= 'valid'
solo las partes en donde no se incluyen bordes emparejados con ceros.
@end table

En forma predeterminada @var{shape} es 'full'. Cuando el tercer argumento es una 
matriz, retorna la convoluci@'on de la matriz @var{M} con el vector @var{v1}
en direcci@'on de las columnas y con el vector @var{v2} en direcci@'on de las filas.
@end deftypefn
