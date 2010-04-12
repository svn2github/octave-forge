md5="6aa679d08aa86d7ed2ed13e9263f83f2";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} fv (@var{r}, @var{n}, @var{p}, @var{l}, @var{method})
Retorna el valor futuro al final del periodo @var{n} de una inversi@'on, 
la cual consta de @var{n} pagos de @var{p} en cada periodo, 
asumiendo una tasa de inter@'es @var{r}.

El argumento opcional @var{l} puede ser usado para especificar 
pagos adicionales.

El argumento adicional @var{method} puede ser usado para especificar si los 
pagos se hacen al final (@code{"e"}, predeterminado) o al inicio (@code{"b"}) 
de cada periodo.

N@'otese que la tasa @var{r} se especifica como una fracci@'on (p.e., 0.05,
no 5 porciento).
@end deftypefn
