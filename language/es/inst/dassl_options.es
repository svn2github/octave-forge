md5="3a59c5a6d19f97ecf29faf4d33950a4d";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {} dassl_options (@var{opt}, @var{val})
Cuando es invocada con dos argumentos, esta función 
permite establecer los parámetros opcionales de la función @code{dassl}.
Dado un argumento, @code{dassl_options} retorna el valor de la 
opción correspondiente. Si no se suministran argumentos, se muestran 
todos los nombres de las opciones disponibles y sus respectivos valores.

Las opciones incluyen 

@table @code
@item "absolute tolerance"
Tolerancia absoluta. Puede ser vector o escalar. Si es un vector, debe 
conicidir con las dimensiones del vector de estados, y la tolerancia 
relativa debe ser un vector de la misma longitud.
@item "relative tolerance"
Tolerancia relativa. Puede ser vecotr o escalar. Si es un vector, debe 
coincidir con las dimensiones del vector de estados, y la tolerancia 
absoluta debe ser un vector de la misma longintud.

La prueba de error local aplicada en cada paso de integración es 

@example
  abs (local error in x(i))
       <= rtol(i) * abs (Y(i)) + atol(i)
@end example
@item "compute consistent initial condition"
Si es distinto de cero, @code{dassl} intentará calcular un conjunto de 
condiciones iniciales consistentes. Esto no es confiable generalmente, lo 
mejor es suministrar un conjunto consistente y asignar cero a esta opción.
@item "enforce nonnegativity constraints"
Si se sabe que las soluciones a de las ecuaciones siempre serán no 
negativas, puede ayudar asignar un valor distinto de cero a este 
parámetro. Sin embargo, probablementente lo mejor es asignar cero a esta 
opci'on primero, y solo asignar un valor distinto de cero si no funciona bien.
@item "initial step size"
Los problemas algebraico-diferenciales pueden sufrir de dificultades 
severas de escalamiento en el primer paso. Si usted sabe acerca de 
dificultades de escalamiento en su problema, es posible aliviar esta 
situación especificando la longitud del paso inicial.
@item "maximum order"
Restringe el orden máximo del método de solución. Esta opción debe estar 
entre 1 y 5.
@item "maximum step size"
Ajustando la longitud máxima del paso se evitará pasar sobre 
regiones grandes (el valor predeterminado es no especificado).
@item "step limit"
Número máximo de pasos de integración a intentar en un llamado 
sencillo al código Fortran subyascente.
@end table
@end deftypefn
