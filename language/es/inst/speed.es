md5="5b844d00084d83f43d2f9dae5d09c81d";rev="6893";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} speed (@var{f}, @var{init}, @var{max_n}, @var{f2}, @var{tol})
@deftypefnx {Archivo de funci@'on} {[@var{order}, @var{n}, @var{T_f}, @var{T_f2}] =} speed (@dots{})

Determina el tiempo de ejecuci@'on de una expresi@'on de varias @var{n}.
Las @var{n} son registradas de 1 a @var{max_n}. Para cada @var{n},
una expresi@'on de inicializaci@'n es calcula para crear los datos que
son necesarios para el test. Si una segunda expresi@'on se da, los
tiempos de ejecuci@'n de las dos expresiones se pueden comparar. Llamar
la funci@'on sin argumentos de salida los resultados ser@'an presentados
gr@'aficamente.

@table @code
@item @var{f}
La expreci@'on para evaluar.

@item @var{max_n}
La longitud m@'axima del test para ejecutar. El valor por defecto es de 100
Alternativamente, utilice @code{[min_n,max_n]} o para un completo control,
@code{[n1,n2,@dots{},nk]}.

@item @var{init}
Expresi@'on de inicializaci@'on para los valores de los argumentos, 
utilice @var{k} para el n@'umero del test y @var{n} para el tama@~{n}o
del test. Esto debe calcular valores para todas las variables en la lista
de argumentos. Note que init ser@'a evaluado desde k=0, as@'i que las 
cosas que son constantes durante todo el test pueden ser calculadas luego.
El valor por defecto es @code{@var{x} = randn (@var{n}, 1);}.

@item @var{f2}
Una expresi@'on alternativa para evaluar, como la velocidad de las dos
puedes ser comparadas. por defecto es @code{[]}.

@item @var{tol}
Si @var{tol} es @code{Inf}, entonces no hay comparaci@'on y se efectuar@'a
entre los resultados de la expresi@'on @var{f} y la expresión @var{f2}.
De otro modo, la expresión @var{f} debe producir un valor @var{v}, y la 
expresión @var{f2} debe producir un valor de @var{v2},y estos ser@'an
comparados utilizando @code{assert(@var{v},@var{v2},@var{tol})}. Si 
@var{tol} es positivo, la tolerancia se supone que es absoluta.
Si @var{tol} es negativa, la tolerancia se supone que es relativa.
El valor predeterminado es @code{eps}.

@item @var{order}
La clomplejidad del tiempo de la expreci@'on @code{O(a n^p)}. Esta es una 
estructura con campos @code{a} y @code{p}.

@item @var{n}
Los valores de @var{n} para qu@'e la expreci@'on sea calculada y el 
tiempo de ejecuci@'on sea mayor que cero.

@item @var{T_f}
Los tiempos de ejecuci@'on registrados diferentes de cero  para la
expresi@'on @var{f} en segundos.

@item @var{T_f2}
Los tiempos de ejecuci@'on registrados diferentes de cero  para la
expresi@'on @var{f2} en segundos.
Si es necesario, la proporci@'on del tiempo medio @'es @code{mean(T_f./T_f2)}.
@end table

La pendiente de la gr@'afica del tiempo de ejecuci@'on muestra la
potencia aproximada del tiempo de ejecuci@'on asint@'otico @code{O(n^p)}.
Esta potencia se traza para la regi@'on sobre la cual se aproxima a ella 
(la segunda mitad de la gr@'afica). La potencia estimada no es muy 
precisa, pero debe ser suficiente para determinar el orden general 
del algoritmo. Debe indicar si por ejemplo su implementaci@'on es 
inesperadamente @code{O(n^2)} en vez de @code{O(n)} porque extiende un 
vector cada vez a trav@'es del bucle en lugar que de reasignar uno 
suficientemente grande. Por ejemplo, en la versi@'on actual de Octave,
lo siguiente no es lo esperado @code{O(n)}:

@example
  speed("for i=1:n,y@{i@}=x(i); end", "", [1000,10000])
@end example

but it is if you preallocate the cell array @code{y}:

@example
  speed("for i=1:n,y@{i@}=x(i);end", ...
        "x=rand(n,1);y=cell(size(x));", [1000,10000])
@end example

Intenta hacer una aproximaci@'on al valor individual de las operaciones,
pero esto es desenfrenadamente inexacto. Puede mejorar un poco la 
estabilidad trabajando mucho m@'as para cada @code{n}. Por ejemplo:

@example
  speed("airy(x)", "x=rand(n,10)", [10000,100000])
@end example

C@'uando compara una expreci@'on nueva y original, la l@'inea sobre el 
incremento de la raz@'on de la gr@'afica puede ser m@'as  grande que 1 si
la nueva expresi@'on es m@'as r@'apida. Los mejores algoritmos tienen una
pendiente superficial, en general, vectorizar un algoritmo  no cambiar@'a 
la pendiente de la gr@'afica del tiempo de ejecuci@'on. Pero lo cambiar@'a
en relaci@'on con la original. Por ejemplo:

@example
  speed("v=sum(x)", "", [10000,100000], ...
        "v=0;for i=1:length(x),v+=x(i);end")
@end example

Un ejemplo m@'as complejo, si usted tuviera una versi@'on original  de 
@code{xcorr} utilizando bucles y otra versi@'on que utilice FFT, podri@'a 
compararla ejecutando speed por varios lapsos de la siguiente manera,
o por un lapso fijo variando la longitud del vector como sigue: 

@example
  speed("v=xcorr(x,n)", "x=rand(128,1);", 100, ...
        "v2=xcorr_orig(x,n)", -100*eps)
  speed("v=xcorr(x,15)", "x=rand(20+n,1);", 100, ...
        "v2=xcorr_orig(x,n)", -100*eps)
@end example

Asumiendo una de las dos versiones est@'e en @var{xcorr_orig}, esto 
comparia su velocidad y sus valores de salida. Note que la versi@'on
FFT no es exacta,  as@'i que especificamos una tolerancia aceptable sobre
la comparci@'on @code{100*eps}, y los errores pueden ser calculados 
relativamente, como @code{abs((@var{x} - @var{y})./@var{y})} en vez
de absolutamente como @code{abs(@var{x} - @var{y})}.

Escriba @code{example('speed')} para ver algunos ejemplos reales. Note
que para las razones desconocidas, no puede ejecutar ejemplos 1 y 2
directamete  usando  @code{demo('speed')}.  En cambio  utilice, 
@code{eval(example('speed',1))} y @code{eval(example('speed',2))}.
@end deftypefn
