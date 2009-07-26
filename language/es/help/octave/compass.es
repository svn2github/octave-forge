md5="58f6101645bf73529d912274820a3aa8";rev="5942";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} compass (@var{u}, @var{v})
@deftypefnx {Archivo de funci@'on} {} compass (@var{z})
@deftypefnx {Archivo de funci@'on} {} compass (@dots{}, @var{style})
@deftypefnx {Archivo de funci@'on} {} compass (@var{h}, @dots{})
@deftypefnx {Archivo de funci@'on} {@var{h} =} compass (@dots{})

Graf@'ica los componentes @code{(@var{u}, @var{v})} de un campo vectorial amanando
desde el orgien de una gr@'afica en coordenadas polares. Si se suministra un @'unico 
argumento complejo @var{z}, @code{@var{u} = real (@var{z})} y @code{@var{v} = imag 
(@var{z})}.

El estilo usado en la gr@'afica puede ser definido con un estilo de l@'inea @var{style}
de manera similar a los estilos de l@'inea usados con el comando @code{plot}.

El valor opcional retornado @var{h} suministra una lista de manejadores a las partes del campo vectorial
 (cuerpo, flecha y marcador).

@example
@group
a = toeplitz([1;randn(9,1)],[1,randn(1,9)]);
compass (eig (a))
@end group
@end example

@seealso{plot, polar, quiver, feather}
@end deftypefn
