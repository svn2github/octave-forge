-*- texinfo -*-
@deftypefn {Funci@'on cargable} {@var{s} =} svd (@var{a})
@deftypefnx {Funci@'on cargable} {[@var{u}, @var{s}, @var{v}] =} svd (@var{a})
@cindex singular value decomposition
Calcular la descomposición de valor singular de @var{a}
@iftex
@tex
$$
 A = U\Sigma V^H
$$
@end tex
@end iftex
@ifinfo

@example
a = u * sigma * v'
@end example
@end ifinfo

La función @code{svd} normalmente devuelve el vector de valores 
singulares.
Si se le pregunta por tres valores de retorno, calcula
@iftex
@tex
$U$, $S$, and $V$.
@end tex
@end iftex
@ifinfo
U, S, y V.
@end ifinfo
Por ejemplo,

@example
svd (hilb (3))
@end example

@noindent
devuelve

@example
ans =

  1.4083189
  0.1223271
  0.0026873
@end example

@noindent
y

@example
[u, s, v] = svd (hilb (3))
@end example

@noindent
devuelve

@example
u =

  -0.82704   0.54745   0.12766
  -0.45986  -0.52829  -0.71375
  -0.32330  -0.64901   0.68867

s =

  1.40832  0.00000  0.00000
  0.00000  0.12233  0.00000
  0.00000  0.00000  0.00269

v =

  -0.82704   0.54745   0.12766
  -0.45986  -0.52829  -0.71375
  -0.32330  -0.64901   0.68867
@end example

Si se le da un segundo argumento, @code{svd} devuelve un economíco-tamaño
de la descomposición, la eliminación de las filas o columnas innecesarias
de @var{u} o @var{v}.
@end deftypefn
