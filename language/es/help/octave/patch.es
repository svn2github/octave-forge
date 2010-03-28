md5="35b04f10098c8e1c726e3335ebb2c2d0";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} patch ()
@deftypefnx {Archivo de funci@'on} {} patch (@var{x}, @var{y}, @var{c})
@deftypefnx {Archivo de funci@'on} {} patch (@var{x}, @var{y}, @var{c}, @var{opts})
@deftypefnx {Archivo de funci@'on} {} patch ('Faces', @var{f}, 'Vertices', @var{v}, @dots{})
@deftypefnx {Archivo de funci@'on} {} patch (@dots{}, @var{prop}, @var{val})
@deftypefnx {Archivo de funci@'on} {} patch (@var{h}, @dots{})
@deftypefnx {Archivo de funci@'on} {@var{h} = } patch (@dots{})
Crear un objeto patch de @var{x} y @var{y} con el color @var{C} y
lo inserta en los ejes actuales del objeto. Regresa una propidedad para
el objeto patch.

Para un patch de color uniforme, @var{C} puede ser dado como un vector 
RGB, refiri@'endose al valor escalar el mapa de colores actual, o una 
cadena de caracteres (por ejemplo, "r" o "rojo").
@end deftypefn