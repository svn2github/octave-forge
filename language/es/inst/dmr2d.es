md5="62243eca23d27de96ab23ab2fcabe7c5";rev="6231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{dsys}, @var{fidx}] =} dmr2d (@var{sys}, @var{idx}, @var{sprefix}, @var{ts2}, @var{cuflg})
Convierte un sistema digital multifrecuencia en un sistema digital de @'unica frecuencia. Los estados especificados por @var{idx}, @var{sprefix} son muestreados 
en @var{ts2}, todos los dem@'as se asumen en 
@var{ts1} = @code{sysgettsam (@var{sys})}.

@strong{Entradas}
@table @var
@item   sys
Sistema en tiempo discreto;
@code{dmr2d} termina la ejecuci@'on con un error si @var{sys} no es discreto 
@item   idx
@'Indices o nombres de los estados con tiempo de muestreo
@code{sysgettsam(@var{sys})} (puede ser vacio); v@'ease @code{cellidx}
@item   sprefix
lista de cadenas de prefijos de los estados con tiempo de muestreo 
@code{sysgettsam(@var{sys})} (puede ser vacio)
@item   ts2 tiempo de muestro de los estados no especificados por @var{idx}, 
@var{sprefix} debe ser m@'ultiplo entero de @code{sysgettsam(@var{sys})}
@item   cuflg
"constante u flag" si @var{cuflg} es distinto de cero, las entradas del sistema se 
asumen constantes sobre el intervalo de muestreo @var{ts2}.
En otro caso, puesto que las entradas pueden cambiar durante el intervalo 
@var{t} en @math{[k ts2, (k+1) ts2]}, se incluye un conjunto adicional en la 
matriz @var{B} tal que estas entradas intermuestas pueden ser incluidas en el 
sistema de frecuencia sencilla. El valor predeterminado es @var{cuflg} = 1.
@end table

@strong{Salidas}
@table @var
@item   dsys
Sistema en tiempo discreto equivalente con tiempo de muestreo @var{ts2}.

El tiempo de muestro @var{sys} se actualiza en @var{ts2}.

Si @var{cuflg}=0, se agrega un conjunto de entradas adicionales al sistema 
con sufijos _d1, @dots{}, _dn para indicar su retraso con respecto al tiempo
inicial k @var{ts2}, p.e. u = [u_1; u_1_d1; @dots{}, u_1_dn] where u_1_dk es 
la entrada @code{k*ts1} unidades de tiempo despues de u_1 es muestreado. 
(@var{ts1} es el tiempo de muestro original del sistema de tiempo discreto y
@var{ts2} = (n+1)*ts1)

@item   fidx
@'indices de los estados "anteriormente r@'apidos" especificados por @var{idx} y  
@var{sprefix}; estos estados se actualizan al internavalo de muestro nuevo 
(m@'as lento) @var{ts2}.
@end table

@strong{ADVERTENCIA} Esta funci@'on no ha sido probada por completo; especialmente 
cuando @var{cuflg} == 0.
@end deftypefn
