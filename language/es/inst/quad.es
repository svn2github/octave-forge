-*- texinfo -*-
@deftypefn {Funci@'on cargable} {[@var{v}, @var{ier}, @var{nfun}, @var{err}] =} quad (@var{f}, @var{a}, @var{b}, @var{tol}, @var{sing})
La integración de una función no lineal de una variable mediante Quadpack.
El primer argumento es el nombre de la función, la función mienbro o de la
función en línea para llamar a calcular el valor del integrando.
Se debe tener la forma

@example
y = f (x)
@end example

@noindent
donde @var{y} y @var{x} son escalares.

Los argumentos segundo y tercero son los límites de la integración.
Uno o ambos pueden ser infinitos.

El argumento opcional  @var{tol} es un vector que especifica la precisión
deseada del resultado. El primer elemento del vector es la tolerancia 
absoluta deseada, y el segundo elemento es la tolerancia deseada en 
relación. Para elegir una prueba única relativa, establezca la tolerancia
absoluta a cero. Para elegir una prueba absoluta, configure la tolerancia
relativa a cero.

El argumento opcional @var{sing} es un vector de valores en los que se
conoce el integrando a ser singular.

El resultado de la integración se devuelve en @var{v} y @var{ier} contiene
un código de error entero (0 indica un éxito de la integración). El valor 
de @var{nfun} indica de muchas funciones de evaluaciones son requeridas, y
@var{err} contiene una estimación del error en la solución.

Usted puede usar la funcion @code{quad_options} para establecer parametros
opcionales para @code{quad}.
@end deftypefn
