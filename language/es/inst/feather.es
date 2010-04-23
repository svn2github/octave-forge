md5="ed59842fb7e369398f970dc37cfff71c";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} feather (@var{u}, @var{v})
@deftypefnx {Archivo de función} {} feather (@var{z})
@deftypefnx {Archivo de función} {} feather (@dots{}, @var{style})
@deftypefnx {Archivo de función} {} feather (@var{h}, @dots{})
@deftypefnx {Archivo de función} {@var{h} =} feather (@dots{})

Grafica los componentes @code{(@var{u}, @var{v})} de un campo vectorial emanando 
desde puntos equidistantes sobre el eje x. Si se da un solo argumento complejo 
@var{z}, entonces @code{@var{u} = real (@var{z})} y 
@code{@var{v} = imag (@var{z})}.

El estilo a usar para las gráficas puede ser definido con una línea de 
estilo @var{style} de manera similar a los estilos de línea utilizados con 
el comando @code{plot}.

El parámetro retornado opcional @var{h} provee una lista de apuntadores a 
las partes del campo vectorial (cuerpo, flechas y marcas).

@example
@group
phi = [0 : 15 : 360] * pi / 180;
feather (sin (phi), cos (phi))
@end group
@end example

@seealso{plot, quiver, compass}
@end deftypefn
