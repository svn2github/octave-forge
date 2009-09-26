md5="ed59842fb7e369398f970dc37cfff71c";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} feather (@var{u}, @var{v})
@deftypefnx {Archivo de funci@'on} {} feather (@var{z})
@deftypefnx {Archivo de funci@'on} {} feather (@dots{}, @var{style})
@deftypefnx {Archivo de funci@'on} {} feather (@var{h}, @dots{})
@deftypefnx {Archivo de funci@'on} {@var{h} =} feather (@dots{})

Grafica los componentes @code{(@var{u}, @var{v})} de un campo vectorial emanando 
desde puntos equidistantes sobre el eje x. Si se da un solo argumento complejo 
@var{z}, entonces @code{@var{u} = real (@var{z})} y 
@code{@var{v} = imag (@var{z})}.

El estilo a usar para las gr@'aficas puede ser definido con una l@'inea de 
estilo @var{style} de manera similar a los estilos de l@'inea utilizados con 
el comando @code{plot}.

El par@'ametro retornado opcional @var{h} provee una lista de manejadores a 
las partes del campo vectorial (cuerpo, flechas y marcas).

@example
@group
phi = [0 : 15 : 360] * pi / 180;
feather (sin (phi), cos (phi))
@end group
@end example

@seealso{plot, quiver, compass}
@end deftypefn
