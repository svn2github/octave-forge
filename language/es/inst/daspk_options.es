md5="d3026b7c2dd0ab3cc9232db05ec3524d";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {} daspk_options (@var{opt}, @var{val})
Cuando se invoca con dos argumentos, esta función 
permite ajustar los paraámetros opcionales de la función @code{daspk}.
Dado un argumento, @code{daspk_options} retorna el valor de la 
opción correspondiente. Si no se suministran argumentos, se muestran los
nombres de todas las opciones disponibles y sus valores actuales.

Entre las opciones se incluyen:

@table @code
@item "absolute tolerance"
Tolerancia absoluta. Puede ser vector o escalar. Si es vector, debe
coincidir con la dimensión del vector de estados, y la tolerancia relativa 
también debe ser un vector de la misma longitud.
@item "relative tolerance"
Tolerania relativa. Puede ser vector o escalar. Si es vector, debe 
coincidir con la dimensión del vecotor de estados, y la tolerancia absoluta 
también debe ser un vector de la misma longitud.

La prueba de error local aplicada en cada paso de integración es

@example
  abs (local error in x(i))
       <= rtol(i) * abs (Y(i)) + atol(i)
@end example
@item "compute consistent initial condition"
Denotando las variables diferenciales en el vector de estados por @samp{Y_d}
y las variables algebráicas por @samp{Y_a}, @code{ddaspk} puede resolver 
uno de los siguientes dos problemas de inicialización:

@enumerate
@item Dado Y_d, calcular Y_a y Y'_d
@item Dado Y', calcular Y.
@end enumerate

En cualquier caso, se ingresan los valores iniciales de 
los componentes dados, y las aproximaciones iniciales de 
los componentes desconocidos. Ajuste esta opción en 1 
para resolver el primer problema, o 2 para resolver el 
segundo (el valor predeterminado es 0, usted debe 
suministrar un conjunto de condiciones iniciales que sean 
consistentes).

Si la opción es establecida en un valor distinto de cero, 
usted debe también ajustar la opción  @code{"algebraic variables"} 
para declarar cuales variables en el problema son algebráicas.
@item "use initial condition heuristics"
Establece a un valor distinto de cero para usar en las 
opciones de condiciones iniciales heurísticas descritas 
a continuación.
@item "initial condition heuristics"
Un vector con los siguientes parámetros que puede ser usado 
para controlar el cálculo de la condición inicial.

@table @codeocasionalmente
@item MXNIT
Número máximo de iteraciones del método de Newton (el 
valor predeterminado es 5).
@item MXNJ
Número máximo de evaluaciones Jacobianas (el valor 
predeterminado es 6).
@item MXNH
Número máximo de valores del parámetro longitud de paso 
artificial a ser intentando si la opción 
@code{"compute consistent initial condition"}  ha sido ejustada 
en (el valor predeterminado es 5).

Nótese que el número total máximo de iteraciones de Newton permitido es 
@code{MXNIT*MXNJ*MXNH} si la opción @code{"compute consistent initial
condition"} ha sido establecida en 1 y @code{MXNIT*MXNJ} si es establecida 
en 2.
@item LSOFF
Establece un valor distinto de cero para deshabilitar el algoritmo linesearch 
(el valor predeterminado es 0).
@item STPTOL
Paso escalado mínimo en el algoritmo linesearch (el valor predeterminado es eps^(2/3)).
@item EPINIT
Factor Asegurar verificación de restricionesde balance en las pruebas de convergencia en una iteración de Newton. 
La prueba es aplicada al vector de residuo, premultiplicado por el Jacobiano 
aproximado. Por convergencia, la norma ponderada RMS de este vector 
(multiplicado por los pesos de los errores) debe ser menor que @code{EPINIT*EPCON},
donde @code{EPCON} = 0.33 es la constante de prueba análoga usada en los pasos. 
El valor predeterminado es @code{EPINIT} = 0.01.
@end table
@item "print initial condition info"
Ajuste esta opción a un valor destinto de cero para mostrar información 
detallada acerca del cálculo de condiciones iniciales (el valor predetermiando es 0).
@item "exclude algebraic variables from error test"
Ajuste esta opción a un valor distinto de cero para excluir las 
variables algebráicas de la prueba de error. También debe 
ajustar la opción @code{"algebraic variables"} para declarar 
cuales variables en el problema son algebráicas (el valor 
predeterminado es 0).
@item "algebraic variables"
Un vector de la misma longitud que el vector de estados. Un elemento
distinto de cero indica que el correspondiente elemento del vector 
de estados es una variable algebráica (p.e., su derivada no aparece 
explicitamente en el conjunto de ecuaciones).

Esta opción es requerida por las opciones 
@code{compute consistent initial condition"} y
@code{"exclude algebraic variables from error test"}.
@item "enforce inequality constraints"
Establece uno de los siguientes valores para asegurar que las restriciones 
de desigualdad especificadas por la opción @code{"inequality constraint types"} 
(el valor predeterminado es 0).

@enumerate
@item Asegurar verificación de restriciones únicamente en el 
cálculo de la condición inicial.
@item Asegurar verificación de restriciones durante la integración.
@item Asegurar opción 1 y 2.
@end enumerate
@item "inequality constraint types"
Un vector de la misma longitud que el vector de estados especificando  
el tipo de restricciones de desigualdad. Cada elemento del vector corresponde a un 
elemento del vector de estado y debería ser asignado uno de los siguientes códigos:

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

Esta opción únicamente tiene afecto si la opción 
@code{"enforce inequality constraints"} es distinta de cero.
@item "initial step size"
Los problemas algebraico-diferenciales pueden ocasionalmente 
sufrir de severas dificultades de escala en el primer paso. 
Si usted sabe acerca de una situación de en donde se presenten 
problemas de escalamiento en su problema, es posible aliviar 
esta situación especificando la longitud inicial del paso (el 
valor predeterminado es calculado automáticamente).
@item "maximum order"
Restringe el máximo orden del método de solución. Esta opción 
debe ser un valor entre 1 y 5 (el valor predeterminado 5).
@item "maximum step size"
Ajustando la máxima longitud del paso se evitará pasar sobre 
regiones muy grandes (el valor predeterminado es no especificado).
@end table
@end deftypefn
