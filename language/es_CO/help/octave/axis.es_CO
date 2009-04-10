md5="1031a873aecf5a1f2da7c554d9f19014";rev="5693";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} axis (@var{limits})
Establece los l@'imites de los ejes para las gr@'aficas.

El argumento @var{limits} deber@'ia ser un vector de 2, 4, o 6 elementos. Los 
dos primeros elementos especifican los l@'imites inferiores y superiores para 
el eje x. El tercero y cuarto especifican los l@'imites para el eje y, y el
quinto y sexto especifican los l@'imites para el eje z.

Sin ning@'un argumento, @code{axis} activa la escala autom@'atica. 

Con un argumento de salida, @code{x=axis} returna los ejes actuales.

El argumento vector que especifica los l@'imites es opcional. Adicionalmente, 
argumentos de cadenas de caracteres pueden ser usados para especificar 
varias propiedades de los ejes. Por ejemplo,

@example
axis ([1, 2, 3, 4], "square");
@end example

@noindent
fuerza una relación de aspecto cuadrado, y

@example
axis ("labely", "tic");
@end example

@noindent
convierte en marcas tic todos los ejes y etiquetas de marcas 
tic para el eje y @'unicamente.

@noindent
Las siguientes opciones controlan la relaci@'on de aspecto de los ejes.

@table @code
@item "square"
Fuerza una relación de aspecto cuadrado.
@item "equal"
Fuerza la distancia en x igual a la distancia en y.
@item "normal"
Restura el balance.
@end table

@noindent
Las siguientes opciones controlan la forma en que los l@'imites de los 
ejes son interpretados.

@table @code
@item "auto" 
Establece el eje especificado para tener l@'imites agradables alrededor 
de los datos o todos si ning@'un eje es especificado.
@item "manual" 
Fija los l@'imites de los ejes actuales.
@item "tight"
Fija los ejes a los l@'imites de los datos (no implementado).
@end table

@noindent
La opci@'on @code{"image"} es equivalente a @code{"tight"} y
@code{"equal"}.

@noindent
Las siguientes opciones afectan la aparariencia de las marcas tic.

@table @code
@item "on" 
Activa las marcas tic y las etiquetas para todos los ejes.
@item "off"
Desactiva las marcas tic para todos los ejes.
@item "tic[xyz]"
Activa las marcas tic para todos los ejes, o las activa para 
los ejes especificados y las desactiva para los restantes.
@item "label[xyz]"
Activa las etiquetas tic para todos los ejes, o las activa para 
los ejes especificados y las desactiva para los restantes.
@item "nolabel"
Desactiva las etiquetas tic para todos los ejes.
@end table
N@'otese, si no hay marcas tic para un eje, no pueden haber etiquetas.

@noindent
Las siguientes opciones afectan la direcci@'on del incremento de los 
valores de los ejes.

@table @code
@item "ij"
Revierte el eje y, los valores m@'as bajos est@'an m@'as cerca del extremo.
@item "xy" 
Restaura el eje y, los valores m@'as altos est@'an m@'as cerca del extremo. 
@end table

Si un manejador de ejes es pasado como primer argumento, entonces opera sobre 
este eje m@'as que sobre el eje actual.
@end deftypefn
