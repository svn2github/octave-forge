md5="4005e6a6381c67b37d86fb59b825c39c";rev="6834";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{method} =} fftw ('planner')
@deftypefnx {Archivo de funci@'on} {} fftw ('planner', @var{method})
@deftypefnx {Archivo de funci@'on} {@var{wisdom} =} fftw ('dwisdom')
@deftypefnx {Archivo de funci@'on} {@var{wisdom} =} fftw ('dwisdom', @var{wisdom})

Administra wisdom data FFTW. Wisdom data puede ser usada para acelerar
significativamente el c@'alculo de las FFTs pero implica un costo inicial
en su c@'alculo. la wisdom usada por Octave puede ser importada 
directamente, por defecto desde un archivo /etc/fftw/wisdom, o la 
funci@'on @dfn{fftw} puede ser utilizada para importar la wisdom,
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

Durante el c@'alculo de la transformada de Fourier una wisdom adicional
es generada. La manera en que la wisdom es generada es igualmente
controlada por la funci@'on @dfn{fftw}. Hay cinco maneras distintas en
que la wisdom puede ser tratada, estas son

@table @asis
@item 'estimate'
Esto espec@'ifica al run-time que n@'o realice una medici@'n de la manera
@'optima al c@'alculo en particular que se esta efectuado, y una 
heur@'istica simple es usada para escoger un plan (probablemente 
sub-optimal). La ventaja de este m@'etodo es que hay poco o nada de gastos
en la generaci@'on del plan, c@'ual es apropiado para una trasnformada de
Fourier eso ser@'a calculado de una v@'ez.

@item 'measure'
En este caso un rango de algoritmos para efectuar la tranformacion es 
considerado y el mejor es selecionado basado en los tiempos de ejecucion.

@item 'patient'
Esto es como 'measure', pero un rango m@'as amplio de algorimos es 
considerado.

@item 'exhaustive'
Esto es como 'measure', pero todos los algoritmos posibles que pueden ser
usados para tratar la transformada son conociderados.

@item 'hybrid'
Cuando la medici@'on del run-time de el algoritmo puede ser costosa, es 
un acuerdo utilizar 'measure' porque se transforma hasta el tama@~{n}o de
8192 y m@'as all@'a de este valor el m@'etod 'estimate' es el usado.
@end table

El m@'etodo por defecto es 'estimate', y el m@'etodo utilizado 
actualmente puede ser consultado con

@example
@var{method} = fftw ('planner')
@end example

el m@'etodo utilizado puede ser establecido usando

@example
fftw ('planner', @var{method})
@end example

Not@'e que la wisdom calculada se perdera cuando reinicia Octave. Sin 
embargo, la wisdom data puede ser recargada si est@'a es salvada en un 
archivo como se describe arriba. Tambi@'en, cualquier archivo system-wide
wisdom que ha sido encontrado puede ser usado. Los archivos de wisdom 
guardados no deben ser usados en diferentes plataformas ya que no ser@'an
eficientes y la posici@'n de calcular la wisdom estar@'a perdida.
@seealso{fft, ifft, fft2, ifft2, fftn, ifftn}
@end deftypefn