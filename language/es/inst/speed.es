md5="5b844d00084d83f43d2f9dae5d09c81d";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} speed (@var{f}, @var{init}, @var{max_n}, @var{f2}, @var{tol})
@deftypefnx {Archivo de función} {[@var{order}, @var{n}, @var{T_f}, @var{T_f2}] =} speed (@dots{})

Determina el tiempo de ejecución de una expresión de varias @var{n}.
Las @var{n} son registradas de 1 a @var{max_n}. Para cada @var{n},
una expresión de inicializaci@'n es calcula para crear los datos que
son necesarios para el test. Si una segunda expresión se da, los
tiempos de ejecuci@'n de las dos expresiones se pueden comparar. Llamar
la función sin argumentos de salida los resultados serán presentados
gráficamente.

@table @code
@item @var{f}
La expreción para evaluar.

@item @var{max_n}
La longitud máxima del test para ejecutar. El valor por defecto es de 100
Alternativamente, utilice @code{[min_n,max_n]} o para un completo control,
@code{[n1,n2,@dots{},nk]}.

@item @var{init}
Expresión de inicialización para los valores de los argumentos, 
utilice @var{k} para el número del test y @var{n} para el tama@~{n}o
del test. Esto debe calcular valores para todas las variables en la lista
de argumentos. Note que init será evaluado desde k=0, así que las 
cosas que son constantes durante todo el test pueden ser calculadas luego.
El valor por defecto es @code{@var{x} = randn (@var{n}, 1);}.

@item @var{f2}
Una expresión alternativa para evaluar, como la velocidad de las dos
puedes ser comparadas. por defecto es @code{[]}.

@item @var{tol}
Si @var{tol} es @code{Inf}, entonces no hay comparación y se efectuará
entre los resultados de la expresión @var{f} y la expresión @var{f2}.
De otro modo, la expresión @var{f} debe producir un valor @var{v}, y la 
expresión @var{f2} debe producir un valor de @var{v2},y estos serán
comparados utilizando @code{assert(@var{v},@var{v2},@var{tol})}. Si 
@var{tol} es positivo, la tolerancia se supone que es absoluta.
Si @var{tol} es negativa, la tolerancia se supone que es relativa.
El valor predeterminado es @code{eps}.

@item @var{order}
La clomplejidad del tiempo de la expreción @code{O(a n^p)}. Esta es una 
estructura con campos @code{a} y @code{p}.

@item @var{n}
Los valores de @var{n} para qué la expreción sea calculada y el 
tiempo de ejecución sea mayor que cero.

@item @var{T_f}
Los tiempos de ejecución registrados diferentes de cero  para la
expresión @var{f} en segundos.

@item @var{T_f2}
Los tiempos de ejecución registrados diferentes de cero  para la
expresión @var{f2} en segundos.
Si es necesario, la proporción del tiempo medio és @code{mean(T_f./T_f2)}.
@end table

La pendiente de la gráfica del tiempo de ejecución muestra la
potencia aproximada del tiempo de ejecución asintótico @code{O(n^p)}.
Esta potencia se traza para la región sobre la cual se aproxima a ella 
(la segunda mitad de la gráfica). La potencia estimada no es muy 
precisa, pero debe ser suficiente para determinar el orden general 
del algoritmo. Debe indicar si por ejemplo su implementación es 
inesperadamente @code{O(n^2)} en vez de @code{O(n)} porque extiende un 
vector cada vez a través del bucle en lugar que de reasignar uno 
suficientemente grande. Por ejemplo, en la versión actual de Octave,
lo siguiente no es lo esperado @code{O(n)}:

@example
  speed("for i=1:n,y@{i@}=x(i); end", "", [1000,10000])
@end example

but it is if you preallocate the cell array @code{y}:

@example
  speed("for i=1:n,y@{i@}=x(i);end", ...
        "x=rand(n,1);y=cell(size(x));", [1000,10000])
@end example

Intenta hacer una aproximación al valor individual de las operaciones,
pero esto es desenfrenadamente inexacto. Puede mejorar un poco la 
estabilidad trabajando mucho más para cada @code{n}. Por ejemplo:

@example
  speed("airy(x)", "x=rand(n,10)", [10000,100000])
@end example

Cúando compara una expreción nueva y original, la línea sobre el 
incremento de la razón de la gráfica puede ser más  grande que 1 si
la nueva expresión es más rápida. Los mejores algoritmos tienen una
pendiente superficial, en general, vectorizar un algoritmo  no cambiará 
la pendiente de la gráfica del tiempo de ejecución. Pero lo cambiará
en relación con la original. Por ejemplo:

@example
  speed("v=sum(x)", "", [10000,100000], ...
        "v=0;for i=1:length(x),v+=x(i);end")
@end example

Un ejemplo más complejo, si usted tuviera una versión original  de 
@code{xcorr} utilizando bucles y otra versión que utilice FFT, podriá 
compararla ejecutando speed por varios lapsos de la siguiente manera,
o por un lapso fijo variando la longitud del vector como sigue: 

@example
  speed("v=xcorr(x,n)", "x=rand(128,1);", 100, ...
        "v2=xcorr_orig(x,n)", -100*eps)
  speed("v=xcorr(x,15)", "x=rand(20+n,1);", 100, ...
        "v2=xcorr_orig(x,n)", -100*eps)
@end example

Asumiendo una de las dos versiones esté en @var{xcorr_orig}, esto 
comparia su velocidad y sus valores de salida. Note que la versión
FFT no es exacta,  así que especificamos una tolerancia aceptable sobre
la comparción @code{100*eps}, y los errores pueden ser calculados 
relativamente, como @code{abs((@var{x} - @var{y})./@var{y})} en vez
de absolutamente como @code{abs(@var{x} - @var{y})}.

Escriba @code{example('speed')} para ver algunos ejemplos reales. Note
que para las razones desconocidas, no puede ejecutar ejemplos 1 y 2
directamete  usando  @code{demo('speed')}.  En cambio  utilice, 
@code{eval(example('speed',1))} y @code{eval(example('speed',2))}.
@end deftypefn
