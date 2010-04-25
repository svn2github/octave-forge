md5="debb9533387f4c9597594e37039f894c";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{zr} =} tzero2 (@var{a}, @var{b}, @var{c}, @var{d}, @var{bal})
Calcula los ceros de transmisión de @var{a}, @var{b}, @var{c}, 
@var{d}.

El argumento @var{bal} es la opción de balance (véase balance); 
su valor predeterminado es @code{"B"}.

Es necesario incorporar el algoritmo @command{mvzero} para aislar 
los ceros finitos; use el comando @command{tzero} en reemplazo.
@end deftypefn
