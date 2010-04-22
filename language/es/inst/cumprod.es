md5="6bf0d24ff478621fd8cdc12621134446";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} cumprod (@var{x}, @var{dim})
Realiza el producto acumulado de los elementos a lo largo de la dimensión @var{dim}. Si
se omite @var{dim}, su valor predeterminado es 1 (productos acumulados en el sentido 
de las columnas).

Como un caso especial, si @var{x} es un vector y se omite @var{dim},
retorna el producto acumulado de los elementos como un vector con 
la misma orientación de @var{x}.
@end deftypefn
