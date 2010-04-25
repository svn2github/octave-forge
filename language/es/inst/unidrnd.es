md5="938dc8465afdce3d717eab1622e9fb74";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} unidrnd (@var{mx});
@deftypefnx {Archivo de función} {} unidrnd (@var{mx}, @var{v});
@deftypefnx {Archivo de función} {} unidrnd (@var{mx}, @var{m}, @var{n}, @dots{});
Retorna valores aleatorios de la distribución uniforme discreta, con 
valores máximos dados por el entero @var{mx}, el cual debe ser un escalar 
o un arreglo multidimensional. 

Si @var{mx} es un escalar, el tama@~{n}o del resultado está especificado 
por el vector @var{v}, o por los argumentos opcionales @var{m}, @var{n}, 
@dots{}. En otro caso, el tama@~{n}o del resultado es igual al tama@~{n}o 
de @var{mx}.
@end deftypefn
