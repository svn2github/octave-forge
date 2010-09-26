-*- texinfo -*-
@deftypefn {Funci@'on cargable} {[@var{v}, @var{ier}, @var{nfun}, @var{err}] =} quad (@var{f}, @var{a}, @var{b}, @var{tol}, @var{sing})
La integraci�n de una funci�n no lineal de una variable mediante Quadpack.
El primer argumento es el nombre de la funci�n, la funci�n mienbro o de la
funci�n en l�nea para llamar a calcular el valor del integrando.
Se debe tener la forma

@example
y = f (x)
@end example

@noindent
donde @var{y} y @var{x} son escalares.

Los argumentos segundo y tercero son los l�mites de la integraci�n.
Uno o ambos pueden ser infinitos.

El argumento opcional  @var{tol} es un vector que especifica la precisi�n
deseada del resultado. El primer elemento del vector es la tolerancia 
absoluta deseada, y el segundo elemento es la tolerancia deseada en 
relaci�n. Para elegir una prueba �nica relativa, establezca la tolerancia
absoluta a cero. Para elegir una prueba absoluta, configure la tolerancia
relativa a cero.

El argumento opcional @var{sing} es un vector de valores en los que se
conoce el integrando a ser singular.

El resultado de la integraci�n se devuelve en @var{v} y @var{ier} contiene
un c�digo de error entero (0 indica un �xito de la integraci�n). El valor 
de @var{nfun} indica de muchas funciones de evaluaciones son requeridas, y
@var{err} contiene una estimaci�n del error en la soluci�n.

Usted puede usar la funcion @code{quad_options} para establecer parametros
opcionales para @code{quad}.
@end deftypefn
