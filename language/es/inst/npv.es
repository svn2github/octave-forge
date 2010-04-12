md5="4dd1b21c0756d428bca877e67dd8d270";rev="6420";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} npv (@var{r}, @var{p}, @var{i})
Retorna el valor presente neto de la serie de pagos irregulares @var{p} 
(p.e., no necesariamente id@'enticos) los cuales ocurren al final de @var{n} 
periodos consecutivos. La variable @var{r} especifica la tasa de interes 
para un periodo y puede ser escalar (tasa constante) o un vector de la 
misma longitud de @var{p}. 

El argumento opcional @var{i} puede ser usado para especificar la 
inversi@'on inicial. 

N@'otese que la tasa @var{r} se debe especificar como una fracci@'on 
(p.e., 0.05, no 5 porciento). 
@seealso{irr, pv}
@end deftypefn
