md5="1486ccd0a2dc20aac1b18dc29cf8003d";rev="6466";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} manova (@var{y}, @var{g})

Realiza el an@'alisis de varianza de un sentido multivariado (MANOVA). 
La meta es probar si la poblaci@'on de medias de @var{p} dimensiones 
tomadas en @var{k} grupos diferentes son todas iguales. Se asume que 
todos los datos son retirados independientemente de distribuciones 
normales de @var{p} dimensiones con la misma matriz de covarianzas.

La matriz de datos est@'a dada por @var{y}. De igual manera, las filas 
corresponden con las observaciones y las columnas con las variables. 
El vector @var{g} especifies grupo de etiquetas correspondiente (p.e., 
n@'umeros desde 1 hasta @var{k}).

El estad@'istico de prueba LR(Wilks' Lambda) y los @var{p} valores aproximados 
son calculados y mostrados.

@end deftypefn
