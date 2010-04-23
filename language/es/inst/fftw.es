md5="4005e6a6381c67b37d86fb59b825c39c";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{method} =} fftw ('planner')
@deftypefnx {Archivo de función} {} fftw ('planner', @var{method})
@deftypefnx {Archivo de función} {@var{wisdom} =} fftw ('dwisdom')
@deftypefnx {Archivo de función} {@var{wisdom} =} fftw ('dwisdom', @var{wisdom})

Administra wisdom data FFTW. Wisdom data puede ser usada para acelerar
significativamente el cálculo de las FFTs pero implica un costo inicial
en su cálculo. la wisdom usada por Octave puede ser importada 
directamente, por defecto desde un archivo /etc/fftw/wisdom, o la 
función @dfn{fftw} puede ser utilizada para importar la wisdom,
por ejemplo

@example
@var{wisdom} = fftw ('dwisdom')
@end example

almacena la existente wisdom usada por Octave en la cadena de caracteres
@var{wisdom}. Esta cadena puede ser almacenada de la manera usual. la 
wisdom existente puedes ser nuevamente importada de la siguiente manera

@example
fftw ('dwisdom', @var{wisdom})
@end example 

Si @var{wisdom} es una matriz nula, la wisdom es borrada.

Durante el cálculo de la transformada de Fourier una wisdom adicional
es generada. La manera en que la wisdom es generada es igualmente
controlada por la función @dfn{fftw}. Hay cinco maneras distintas en
que la wisdom puede ser tratada, estas son

@table @asis
@item 'estimate'
Esto específica al run-time que nó realice una medici@'n de la manera
óptima al cálculo en particular que se esta efectuado, y una 
heurística simple es usada para escoger un plan (probablemente 
sub-optimal). La ventaja de este método es que hay poco o nada de gastos
en la generación del plan, cúal es apropiado para una trasnformada de
Fourier eso será calculado de una véz.

@item 'measure'
En este caso un rango de algoritmos para efectuar la tranformacion es 
considerado y el mejor es selecionado basado en los tiempos de ejecucion.

@item 'patient'
Esto es como 'measure', pero un rango más amplio de algorimos es 
considerado.

@item 'exhaustive'
Esto es como 'measure', pero todos los algoritmos posibles que pueden ser
usados para tratar la transformada son conociderados.

@item 'hybrid'
Cuando la medición del run-time de el algoritmo puede ser costosa, es 
un acuerdo utilizar 'measure' porque se transforma hasta el tama@~{n}o de
8192 y más allá de este valor el métod 'estimate' es el usado.
@end table

El método por defecto es 'estimate', y el método utilizado 
actualmente puede ser consultado con

@example
@var{method} = fftw ('planner')
@end example

el método utilizado puede ser establecido usando

@example
fftw ('planner', @var{method})
@end example

Noté que la wisdom calculada se perdera cuando reinicia Octave. Sin 
embargo, la wisdom data puede ser recargada si está es salvada en un 
archivo como se describe arriba. También, cualquier archivo system-wide
wisdom que ha sido encontrado puede ser usado. Los archivos de wisdom 
guardados no deben ser usados en diferentes plataformas ya que no serán
eficientes y la posici@'n de calcular la wisdom estará perdida.
@seealso{fft, ifft, fft2, ifft2, fftn, ifftn}
@end deftypefn