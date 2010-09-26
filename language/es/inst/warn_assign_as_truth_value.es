-*- texinfo -*-
@defvr {Variable incorporada} warn_assign_as_truth_value
Si el valor de @code{warn_assign_as_truth_value} es es zero, 
se emite una advertencia para las declaraciones como

@example
if (s = t)
  ...
@end example

@noindent
ya que dichas declaraciones no son comunes, y es probable que la
intención fue escribir

@example
if (s == t)
  ...
@end example

@noindent
en lugar.

Hay veces en que es útil para escribir código que contiene
asignaciones dentro de la condición de una declaración @code{while}
o @code{if}. Por ejemplo, declaraciones como

@example
while (c = getc())
  ...
@end example

@noindent
esto es común en programcion en C

Es posible evitar todas las advertencias acerca de dichas declaraciones
mediante el establecimiento de @code{warn_assign_as_truth_value} en 0, 
pero que también podría hacer que los errores reales como

@example
if (x = 1)  # intended to test (x == 1)!
  ...
@end example

@noindent
pasen.

En estos casos, es posible suprimir los errores de las declaraciones 
específicas por escrito con un conjunto adicional de paréntesis. 
Por ejemplo, escribir el ejemplo anterior como

@example
while ((c = getc()))
  ...
@end example

@noindent
evitará que la advertencia de que se está imprimiendo para esta 
declaración, al tiempo que permite Octave para advertir acerca de otras
tareas utilizadas en contextos condicional.

El valor predeterminado de @code{warn_assign_as_truth_value} es 1.
@end defvr
