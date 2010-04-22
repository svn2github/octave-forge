md5="194ff68fcf189f779cc763af49dd2f56";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {y =} conv2 (@var{a}, @var{b}, @var{shape})
@deftypefnx {Función cargable} {y =} conv2 (@var{v1}, @var{v2}, @var{M}, @var{shape})

Retorna la convolución 2-D de @var{a} y @var{b} donde el tama@~{n}o 
de @var{c} está dado por:

@table @asis
@item @var{shape}= 'full'
retorna convolución 2-D completa.
@item @var{shape}= 'same'
el mismo tama@~{n}o que @var{a}. Parte 'central' de la convolución.
@item @var{shape}= 'valid'
solo las partes en donde no se incluyen bordes emparejados con ceros.
@end table

En forma predeterminada @var{shape} es 'full'. Cuando el tercer argumento es una 
matriz, retorna la convolución de la matriz @var{M} con el vector @var{v1}
en dirección de las columnas y con el vector @var{v2} en dirección de las filas.
@end deftypefn
