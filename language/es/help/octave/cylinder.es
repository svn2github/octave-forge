md5="d82542b9610fa1c757790fcbee294d97";rev="5971";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} cylinder
@deftypefnx {Archivo de funci@'on} {} cylinder (@var{r})
@deftypefnx {Archivo de funci@'on} {} cylinder (@var{r}, @var{n})
@deftypefnx {Archivo de funci@'on} {[@var{x}, @var{y}, @var{z}] =} cylinder (@dots{})
@deftypefnx {Archivo de funci@'on} {} cylinder (@var{ax}, @dots{})
Genera tres matrices en formato @code{meshgrid}, tal que 
@code{surf (@var{x}, @var{y}, @var{z})} genera un cilindro unitario.
Las matrices son de tama@~{n}o @code{@var{n}+1} por @code{@var{n}+1}. 
@var{r} es un vector que contiene el radio a lo largo del eje z.
Si se omite @var{n} o @var{r}, se asumen los valores predeterminados de 20 o [1 1].

Si se llama sin argumentos, @code{cylinder} llama directamente 
@code{surf (@var{x}, @var{y}, @var{z})}. Si se pasa un manejador de ejes @var{ax} 
como primer argumento, se grafica la superficie en este conjunto de ejes.

Examples:
@example
disp ("graficar un cono")
[x, y, z] = cylinder (10:-1:0,50);
surf (x, y, z);
@end example
@seealso{sphere}
@end deftypefn
