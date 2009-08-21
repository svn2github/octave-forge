md5="3a59c5a6d19f97ecf29faf4d33950a4d";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {} dassl_options (@var{opt}, @var{val})
Cuando es invocada con dos argumentos, esta funci@'on 
permite establecer los par@'ametros opcionales de la funci@'on @code{dassl}.
Dado un argumento, @code{dassl_options} retorna el valor de la 
opci@'on correspondiente. Si no se suministran argumentos, se muestran 
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

La prueba de error local aplicada en cada paso de integraci@'on es 

@example
  abs (local error in x(i))
       <= rtol(i) * abs (Y(i)) + atol(i)
@end example
@item "compute consistent initial condition"
Si es distinto de cero, @code{dassl} intentar@'a calcular un conjunto de 
condiciones iniciales consistentes. Esto no es confiable generalmente, lo 
mejor es suministrar un conjunto consistente y asignar cero a esta opci@'on.
@item "enforce nonnegativity constraints"
Si se sabe que las soluciones a de las ecuaciones siempre ser@'an no 
negativas, puede ayudar asignar un valor distinto de cero a este 
par@'ametro. Sin embargo, probablementente lo mejor es asignar cero a esta 
opci'on primero, y solo asignar un valor distinto de cero si no funciona bien.
@item "initial step size"
Los problemas algebraico-diferenciales pueden sufrir de dificultades 
severas de escalamiento en el primer paso. Si usted sabe acerca de 
dificultades de escalamiento en su problema, es posible aliviar esta 
situaci@'on especificando la longitud del paso inicial.
@item "maximum order"
Restringe el orden m@'aximo del m@'etodo de soluci@'on. Esta opci@'on debe estar 
entre 1 y 5.
@item "maximum step size"
Ajustando la longitud m@'axima del paso se evitar@'a pasar sobre 
regiones grandes (el valor predeterminado es no especificado).
@item "step limit"
N@'umero m@'aximo de pasos de integraci@'on a intentar en un llamado 
sencillo al c@'odigo Fortran subyascente.
@end table
@end deftypefn
