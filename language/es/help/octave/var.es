md5="adbc2da621123b4a0c5e583e5f658edb";rev="6433";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} var (@var{x})
Para vectores, retorna la varianza (real) de los valores. Para matrices, 
retorna un vector fila con las variazas de cada columna. 

El argumento @var{opt} determina el tipo de normalizaci@'on que se va a 
usar.

Los valores v@'alidos son 

@table @asis 
@item 0:
Normaliza con @math{N-1}, provee el mejor estimador no visiado de la 
variaza [predeterminado].
@item 1:
Normaliza con @math{N}, provee el segundo momento en torno en torno a 
la media.
@end table

El tercer argumento @var{dim} determina la dimensic@'on a lo largo de la 
cual se va a calcular la varianza. 
@end deftypefn
