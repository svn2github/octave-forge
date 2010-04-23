md5="3f74f0d32944792eefd48aa40828a077";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} durbinlevinson (@var{c}, @var{oldphi}, @var{oldv})
Ejecuta una iteración del algoritmo de Durbin-Levinson.

El vector @var{c} especifica las autocovarianzas @code{[gamma_0, @dots{},
gamma_t]} desde retraso 0 hasta @var{t}, @var{oldphi} especifica los 
coeficientes basedo en @var{c}(@var{t}-1) y @var{oldv} especifica el 
error correspondiente.

Si se omiten @var{oldphi} y @var{oldv}, se ejecutan todas las iteraciones 
del algoritmo desde 1 hasta @var{t}.
@end deftypefn
