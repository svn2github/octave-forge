md5="508b7ecc2d7c8917b0524fe3adf799de";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} saveimage (@var{file}, @var{x}, @var{fmt}, @var{map})
Guardar la matriz @var{x} en @var{file} en formato imagen @var{fmt}.
Los valores v@'alidos para @var{fmt} son

@table @code
@item "img"
Formato de imagen Octave. El actual mapa de colores es salvado en el 
archivo

@item "ppm"
Formato de mapa de p@'ixeles port@'atil.

@item "ps"
En formato PostScript. Tenga en cuenta que las im@'agenes guardadas en
formato PostScript no se pueden leer de nuevo en Octave con LoadImage.

@end table

Si no se proporciona el cuarto argumento, el mapa de colores especificado
tambi@'en se guardar@'a junto con la imagen.

Nota: si el mapa de colores contiene s@'olo dos entradas y estas entradas
son en blanco y negro, los formatos de mapas de bits ppm y PostScript son
utilizados. Si la imagen es una imagen en escala de grises (las entradas
dentro de cada fila del mapa de colores son iguales) los formatos de 
imagen en la escala de grises ppm y PostScript son utilizados, de otra 
manera se utilizan los formatos de color.

@seealso{loadimage, save, load, colormap}
@end deftypefn
