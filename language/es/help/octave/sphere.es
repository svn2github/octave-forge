md5="5844afa2af2ccecfc1f5b1f4a45edbac";rev="6461";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{x}, @var{y}, @var{z}] =} sphere (@var{n})
@deftypefnx {Archivo de funci@'on} {} sphere (@var{h}, @dots{})
Genera tres matrices en formato @code{meshgrid}, tales que 
@code{surf (@var{x}, @var{y}, @var{z})} genera una esfera unitaria. 
Las matrices tienen dimensiones @code{@var{n}+1} por @code{@var{n}+1}. 
Si se omite @var{n}, se asume el valor 20.

Cuando se llama sin argumentos de retorno, @code{sphere} llama directamente 
@code{surf (@var{x}, @var{y}, @var{z})}. Si se pasa un apuntador a ejes como 
primer argumento, se grafica la superficie en este conjunto de ejes.
@seealso{peaks}
@end deftypefn
