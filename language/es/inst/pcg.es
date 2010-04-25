md5="799992c0eaeda54ccbaf2b01e0f54505";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{x} =} pcg (@var{a}, @var{b}, @var{tol}, @var{maxit}, @var{m1}, @var{m2}, @var{x0}, @dots{})
@deftypefnx {Archivo de función} {[@var{x}, @var{flag}, @var{relres}, @var{iter}, @var{resvec}, @var{eigest}] =} pcg (@dots{})

Resuelve el sistema de ecuaciones lineales @code{@var{a} * @var{x} =
@var{b}} mediante el método iterativo de gradiente conjudado 
precondicionado. Los argumentos de entrada son: 

@itemize
@item
La variable @var{a} puede ser una matriz cuadrada (preferiblemente dispersa), 
un apuntador de función, función en línea o cadena con el nombre de 
una función que calcula @code{@var{a} * @var{x}}. En principio 
@var{a} debería ser simétrica y positiva definida; si @code{pcg} 
encuentra que @var{a} no es positiva definida, se muestra una advertencia 
y se establece el valor del parámetro de salida @var{flag}.

@item
La variable @var{b} es el vector del lado derecho.

@item
La variable @var{tol} es la tolerancia relativa requerida por el error 
residual, @code{@var{b} - @var{a} * @var{x}}. La iteración se detiene si 
@code{norm (@var{b} - @var{a} * @var{x}) <= @var{tol} * norm (@var{b} - 
@var{a} * @var{x0})}. Si se omite @var{tol} o es vacio, la función asigna 
como valor predeterminado @code{@var{tol} = 1e-6}.

@item
La variable @var{maxit} es el máximo número de iteraciones permitidas; si 
se ingresa @code{[]}, o @code{pcg} tiene menos argumentos, se usa 20 como 
valor predeterminado.

@item
@var{m} = @var{m1} * @var{m2} es la matriz precondicionante (izquierda), tal 
que la iteración es equivalente (teóricamente) a resolver @code{pcg} 
@code{@var{P} * @var{x} = @var{m} \ @var{b}}, con @code{@var{P} = @var{m} \ 
@var{a}}. Nótese que la selección apropiada del precondicionador puede 
mejorar dramáticamente el desempe@~{n}o general del método. En lugar 
de las matrices @var{m1} y @var{m2}, el usuario puede pasar dos funciones que 
retornan el resultado de aplicar la inversa de @var{m1} y @var{m2} a un 
vector (usualmente esta es la forma preferida de usar el precondicionador). 
Si se suministra @code{[]} para @var{m1}, o se omite @var{m1}, no se aplica 
precondicionador. Si se omite @var{m2}, se usa como precondicionador 
@var{m} = @var{m1}.

@item
La variable @var{x0} es la solución inicial. Si se omite @var{x0} o es 
vacio, la función asigna a @var{x0} el vector nulo en forma predeterminada. 
@end itemize

Los argumentos pasados después de @var{x0} son tratados como parámetros, 
y pasados en forma apropiada a las funciones de (@var{a} o @var{m}) 
@code{pcg}. Véase los ejemplos a continuación para más detalles. Los 
argumentos de salida son: 

@itemize
@item
La variable @var{x} es la aproximación calculada de la solución de 
@code{@var{a} * @var{x} = @var{b}}.

@item
La variable @var{flag} informa acerca de la convergencia. Si @code{@var{flag} 
= 0}, la solución converge y el criterio de tolerancia dado por @var{tol} 
se satisface. Si @code{@var{flag} = 1}, se ha alcanzado el límite 
@var{maxit} para las iteraciones. Si @code{@var{flag} = 3}, la matriz 
(precondicionada) no es positiva definida.

@item
La variable @var{relres} es la proporción entre el residuo final y su valor 
inicial medido como la norma Euclideana.

@item
La variable @var{iter} es el número real de iteraciones.

@item 
La variable @var{resvec} describe el historial de covergencia del método. 
@code{@var{resvec} (i,1)} es la norma Euclideana del residuo, y 
@code{@var{resvec} (i,2)} es la norma del residuo precondicionado, 
depués de la (@var{i}-1)-ésima iteración, @code{@var{i} =
1, 2, @dots{}, @var{iter}+1}. La norma del residuo precondicionado se 
define como 
@code{norm (@var{r}) ^ 2 = @var{r}' * (@var{m} \ @var{r})} donde 
@code{@var{r} = @var{b} - @var{a} * @var{x}}, véase también la 
descripción de @var{m}. Si no es requerido @var{eigest}, solo se retorna 
@code{@var{resvec} (:,1)}.

@item
La variable @var{eigest} retorna un estimativo de los valores propios 
@code{@var{eigest} (1)} más peque@~{n}os y @code{@var{eigest} (2)} más 
grandes de la matriz precondicionada @code{@var{P} = @var{m} \ @var{a}}. En 
particular, si no se usa ningún precondicionador, se retornan los 
estimadores de los valores propios extremos de @var{a}. El valor de 
@code{@var{eigest} (1)} es un sobreestimado y @code{@var{eigest} (2)} es un 
subestimado, tal que @code{@var{eigest} (2) / @var{eigest} (1)} es el límite 
inferior de @code{cond (@var{P}, 2)}, el cual est@r'ia limitado teóricamente 
por el valor del número de condición. El método utilizado para calcular 
@var{eigest} solo funciona para @var{a} y @var{m} simétrica positiva 
definida, y el usuario es responsable de verificar esta hipótesis. 
@end itemize

Considere el problema trivial con una matriz diagonal (en donde se explota 
el hecho de que A es una matriz dispersa)

@example
@group
	N = 10; 
	A = spdiag ([1:N]);
	b = rand (N, 1);
     [L, U, P, Q] = luinc (A,1.e-3);
@end group
@end example

@sc{Ejemplo 1:} El uso más simple de @code{pcg}

@example
  x = pcg(A,b)
@end example

@sc{Ejemplo 2:} @code{pcg} con una función que calcula 
@code{@var{a} * @var{x}}

@example
@group
  function y = applyA (x)
    y = [1:N]'.*x; 
  endfunction

  x = pcg ("applyA", b)
@end group
@end example

@sc{Ejemplo 3:} @code{pcg} con un precondicionador: @var{l} * @var{u}

@example
x=pcg(A,b,1.e-6,500,L*U);
@end example

@sc{Ejemplo 4:} @code{pcg} con un precondicionador: @var{l} * @var{u}.
Más rápido que @sc{Ejemplo 3} puesto que las matrices triangular 
superior e inferior son más fáciles de invertir

@example
x=pcg(A,b,1.e-6,500,L,U);
@end example

@sc{Ejemplo 5:} Iteración precondicionada, con diagnótico completo. El 
precondicionador (extra@~{n}o, porque resulta en la matriz original 
@var{a}) está definido como una función

@example
@group
  function y = applyM(x)
    K = floor (length (x) - 2);
    y = x;
    y(1:K) = x(1:K)./[1:K]';
  endfunction

  [x, flag, relres, iter, resvec, eigest] = ...
                     pcg (A, b, [], [], "applyM");
  semilogy (1:iter+1, resvec);
@end group
@end example

@sc{Ejemplo 6:} Finalmente, un precondiionador que depende en el paránetro 
@var{k}.

@example
@group
  function y = applyM (x, varargin)
  K = varargin@{1@}; 
  y = x;
  y(1:K) = x(1:K)./[1:K]';
  endfunction

  [x, flag, relres, iter, resvec, eigest] = ...
       pcg (A, b, [], [], "applyM", [], [], 3)
@end group
@end example

@sc{Referencias}

	[1] C.T.Kelley, 'Iterative methods for linear and nonlinear equations',
	SIAM, 1995 (algoritmo base de PCG) 
	
	[2] Y.Saad, 'Iterative methods for sparse linear systems', PWS 1996
	(estimación del número de condición de PCG) La versión revisada 
  del libro está disponible en http://www-users.cs.umn.edu/~saad/books.html


@seealso{sparse, pcr}
@end deftypefn
