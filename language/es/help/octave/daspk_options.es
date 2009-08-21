md5="d3026b7c2dd0ab3cc9232db05ec3524d";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {} daspk_options (@var{opt}, @var{val})
Cuando se invoca con dos argumentos, esta funci@'on 
permite ajustar los para@'ametros opcionales de la funci@'on @code{daspk}.
Dado un argumento, @code{daspk_options} retorna el valor de la 
opci@'on correspondiente. Si no se suministran argumentos, se muestran los
nombres de todas las opciones disponibles y sus valores actuales.

Entre las opciones se incluyen:

@table @code
@item "absolute tolerance"
Tolerancia absoluta. Puede ser vector o escalar. Si es vector, debe
coincidir con la dimensi@'on del vector de estados, y la tolerancia relativa 
tambi@'en debe ser un vector de la misma longitud.
@item "relative tolerance"
Tolerania relativa. Puede ser vector o escalar. Si es vector, debe 
coincidir con la dimensi@'on del vecotor de estados, y la tolerancia absoluta 
tambi@'en debe ser un vector de la misma longitud.

La prueba de error local aplicada en cada paso de integraci@'on es

@example
  abs (local error in x(i))
       <= rtol(i) * abs (Y(i)) + atol(i)
@end example
@item "compute consistent initial condition"
Denotando las variables diferenciales en el vector de estados por @samp{Y_d}
y las variables algebr@'aicas por @samp{Y_a}, @code{ddaspk} puede resolver 
uno de los siguientes dos problemas de inicializaci@'on:

@enumerate
@item Dado Y_d, calcular Y_a y Y'_d
@item Dado Y', calcular Y.
@end enumerate

En cualquier caso, se ingresan los valores iniciales de 
los componentes dados, y las aproximaciones iniciales de 
los componentes desconocidos. Ajuste esta opci@'on en 1 
para resolver el primer problema, o 2 para resolver el 
segundo (el valor predeterminado es 0, usted debe 
suministrar un conjunto de condiciones iniciales que sean 
consistentes).

Si la opci@'on es establecida en un valor distinto de cero, 
usted debe tambi@'en ajustar la opci@'on  @code{"algebraic variables"} 
para declarar cuales variables en el problema son algebr@'aicas.
@item "use initial condition heuristics"
Establece a un valor distinto de cero para usar en las 
opciones de condiciones iniciales heur@'isticas descritas 
a continuaci@'on.
@item "initial condition heuristics"
Un vector con los siguientes par@'ametros que puede ser usado 
para controlar el c@'alculo de la condici@'on inicial.

@table @codeocasionalmente
@item MXNIT
N@'umero m@'aximo de iteraciones del m@'etodo de Newton (el 
valor predeterminado es 5).
@item MXNJ
N@'umero m@'aximo de evaluaciones Jacobianas (el valor 
predeterminado es 6).
@item MXNH
N@'umero m@'aximo de valores del par@'ametro longitud de paso 
artificial a ser intentando si la opci@'on 
@code{"compute consistent initial condition"}  ha sido ejustada 
en (el valor predeterminado es 5).

N@'otese que el n@'umero total m@'aximo de iteraciones de Newton permitido es 
@code{MXNIT*MXNJ*MXNH} si la opci@'on @code{"compute consistent initial
condition"} ha sido establecida en 1 y @code{MXNIT*MXNJ} si es establecida 
en 2.
@item LSOFF
Establece un valor distinto de cero para deshabilitar el algoritmo linesearch 
(el valor predeterminado es 0).
@item STPTOL
Paso escalado m@'inimo en el algoritmo linesearch (el valor predeterminado es eps^(2/3)).
@item EPINIT
Factor Asegurar verificaci@'on de restricionesde balance en las pruebas de convergencia en una iteraci@'on de Newton. 
La prueba es aplicada al vector de residuo, premultiplicado por el Jacobiano 
aproximado. Por convergencia, la norma ponderada RMS de este vector 
(multiplicado por los pesos de los errores) debe ser menor que @code{EPINIT*EPCON},
donde @code{EPCON} = 0.33 es la constante de prueba an@'aloga usada en los pasos. 
El valor predeterminado es @code{EPINIT} = 0.01.
@end table
@item "print initial condition info"
Ajuste esta opci@'on a un valor destinto de cero para mostrar informaci@'on 
detallada acerca del c@'alculo de condiciones iniciales (el valor predetermiando es 0).
@item "exclude algebraic variables from error test"
Ajuste esta opci@'on a un valor distinto de cero para excluir las 
variables algebr@'aicas de la prueba de error. Tambi@'en debe 
ajustar la opci@'on @code{"algebraic variables"} para declarar 
cuales variables en el problema son algebr@'aicas (el valor 
predeterminado es 0).
@item "algebraic variables"
Un vector de la misma longitud que el vector de estados. Un elemento
distinto de cero indica que el correspondiente elemento del vector 
de estados es una variable algebr@'aica (p.e., su derivada no aparece 
explicitamente en el conjunto de ecuaciones).

Esta opci@'on es requerida por las opciones 
@code{compute consistent initial condition"} y
@code{"exclude algebraic variables from error test"}.
@item "enforce inequality constraints"
Establece uno de los siguientes valores para asegurar que las restriciones 
de desigualdad especificadas por la opci@'on @code{"inequality constraint types"} 
(el valor predeterminado es 0).

@enumerate
@item Asegurar verificaci@'on de restriciones @'unicamente en el 
c@'alculo de la condici@'on inicial.
@item Asegurar verificaci@'on de restriciones durante la integraci@'on.
@item Asegurar opci@'on 1 y 2.
@end enumerate
@item "inequality constraint types"
Un vector de la misma longitud que el vector de estados especificando  
el tipo de restricciones de desigualdad. Cada elemento del vector corresponde a un 
elemento del vector de estado y deber@'ia ser asignado uno de los siguientes c@'odigos:

@table @asis
@item -2
Menor que cero.
@item -1
Menor o igual que cero.
@item 0
Sin restriciones.
@item 1
Mayor o igual que cero.
@item 2
Mayor que cero.
@end table

Esta opci@'on @'unicamente tiene afecto si la opci@'on 
@code{"enforce inequality constraints"} es distinta de cero.
@item "initial step size"
Los problemas algebraico-diferenciales pueden ocasionalmente 
sufrir de severas dificultades de escala en el primer paso. 
Si usted sabe acerca de una situaci@'on de en donde se presenten 
problemas de escalamiento en su problema, es posible aliviar 
esta situaci@'on especificando la longitud inicial del paso (el 
valor predeterminado es calculado autom@'aticamente).
@item "maximum order"
Restringe el m@'aximo orden del m@'etodo de soluci@'on. Esta opci@'on 
debe ser un valor entre 1 y 5 (el valor predeterminado 5).
@item "maximum step size"
Ajustando la m@'axima longitud del paso se evitar@'a pasar sobre 
regiones muy grandes (el valor predeterminado es no especificado).
@end table
@end deftypefn
