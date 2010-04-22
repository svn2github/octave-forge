md5="1031a873aecf5a1f2da7c554d9f19014";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} axis (@var{limits})
Establece los límites de los ejes para las gráficas.

El argumento @var{limits} debería ser un vector de 2, 4, o 6 elementos. Los 
dos primeros elementos especifican los límites inferiores y superiores para 
el eje x. El tercero y cuarto especifican los límites para el eje y, y el
quinto y sexto especifican los límites para el eje z.

Sin ningún argumento, @code{axis} activa la escala automática. 

Con un argumento de salida, @code{x=axis} returna los ejes actuales.

El argumento vector que especifica los límites es opcional. Adicionalmente, 
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
tic para el eje y únicamente.

@noindent
Las siguientes opciones controlan la relación de aspecto de los ejes.

@table @code
@item "square"
Fuerza una relación de aspecto cuadrado.
@item "equal"
Fuerza la distancia en x igual a la distancia en y.
@item "normal"
Restura el balance.
@end table

@noindent
Las siguientes opciones controlan la forma en que los límites de los 
ejes son interpretados.

@table @code
@item "auto" 
Establece el eje especificado para tener límites agradables alrededor 
de los datos o todos si ningún eje es especificado.
@item "manual" 
Fija los límites de los ejes actuales.
@item "tight"
Fija los ejes a los límites de los datos (no implementado).
@end table

@noindent
La opción @code{"image"} es equivalente a @code{"tight"} y
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
Nótese, si no hay marcas tic para un eje, no pueden haber etiquetas.

@noindent
Las siguientes opciones afectan la dirección del incremento de los 
valores de los ejes.

@table @code
@item "ij"
Revierte el eje y, los valores más bajos están más cerca del extremo.
@item "xy" 
Restaura el eje y, los valores más altos están más cerca del extremo. 
@end table

Si un apuntador de ejes es pasado como primer argumento, entonces opera sobre 
este eje más que sobre el eje actual.
@end deftypefn
