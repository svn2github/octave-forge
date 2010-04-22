md5="58f6101645bf73529d912274820a3aa8";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} compass (@var{u}, @var{v})
@deftypefnx {Archivo de función} {} compass (@var{z})
@deftypefnx {Archivo de función} {} compass (@dots{}, @var{style})
@deftypefnx {Archivo de función} {} compass (@var{h}, @dots{})
@deftypefnx {Archivo de función} {@var{h} =} compass (@dots{})

Grafíca los componentes @code{(@var{u}, @var{v})} de un campo vectorial amanando
desde el orgien de una gráfica en coordenadas polares. Si se suministra un único 
argumento complejo @var{z}, @code{@var{u} = real (@var{z})} y @code{@var{v} = imag 
(@var{z})}.

El estilo usado en la gráfica puede ser definido con un estilo de línea @var{style}
de manera similar a los estilos de línea usados con el comando @code{plot}.

El valor opcional retornado @var{h} suministra una lista de apuntadores a las partes del campo vectorial
 (cuerpo, flecha y marcador).

@example
@group
a = toeplitz([1;randn(9,1)],[1,randn(1,9)]);
compass (eig (a))
@end group
@end example

@seealso{plot, polar, quiver, feather}
@end deftypefn
