md5="849677ab37cffb5c4cb366cc2f20e1ff";rev="6287";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} synthesis (@var{y}, @var{c})
Calcula una se@~{n}al a partir de la transfomada de tiempo corto de 
Fourier @var{y} y un vector de tres elementos @var{c} especificando 
el tama@~{n}o de la ventana, incremento, y el tipo de ventana.

Los valores de @var{y} y @var{c} puede ser obtenidos mediante 

@example
[@var{y}, @var{c}] = stft (@var{x} , @dots{})
@end example
@end deftypefn
