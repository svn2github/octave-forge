md5="b70788329a9ea6e6e4d34504d074a971";rev="5716";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{mag}, @var{phase}, @var{w}] =} bode (@var{sys}, @var{w}, @var{out_idx}, @var{in_idx})
Si no se dan argumentos de salida: produce los diagramas de Bode de 
un sistema; de lo contrario, calcula la respuesta en frecuencia 
de la estructura de datos del sistema.

@strong{Inputs}
@table @var
@item   sys
estructura de datos del sistema (deben ser continuos o discretos puramente;
v@'ease is_digital)
@item   w
valores de frecuencias para la evaluaci@'on.

Si @var{sys} es continua, la funci@'on @code{bode} evalua @math{G(jw)} donde
@math{G(s)} es la funci@'on de transferencia del sistema.

Si @var{sys} es discreta, la funci@'on @code{bode} evalua G(@code{exp}(jwT)), donde
@itemize @bullet
@item @math{T} es el tiempo de muestreo del sistema.
@item @math{G(z)} es la funci@'on de transferencia del sistema.
@end itemize

@strong{Default} el rango de frecuencias predeterminadas se selecciona como
sigue (Estos pasos @strong{no} son realizados si @var{w} se especifica):
@enumerate
@item Por medio de la rutina __bodquist__, se aislan todos los polos y zeros de 
@var{w}=0 (@var{jw}=0 o @math{@code{exp}(jwT)}=1) y se selecciona el rango de 
frecuencias con base en la ubicaci@'on del punto de corte de las frecuencias.
@item Si @var{sys} es de tiempo discreto, el rango de frecuencias se limita a 
@math{jwT} en
@ifinfo
[0,2 pi /T]
@end ifinfo
@iftex
@tex
$[0,2\pi/T]$
@end tex
@end iftex
@item Una rutina de ``suavizado'' se usa para asegurar que el diagrama de fase no cambie excesivamente entre punto y punto y que las singularidades (p.e., cruces en +/- 180) se muestran con precisi@'on.

@end enumerate
@item out_idx
@itemx in_idx

Los nombres o los @'indices de salidas y entradas a ser utilizados en la 
respuesta de frecuencia. V@'ease @code{sysprune}.

@strong{Example}
@example
bode(sys,[],"y_3", @{"u_1","u_4"@});
@end example
@end table
@strong{Outputs}
@table @var
@item mag
@itemx phase
la magnitud y la fase de la respuesta en frecuencia utilizan @math{G(jw)} o
@math{G(@code{exp}(jwT))} en los valores de frecuencias seleccionados.
@item w
el vector de valores de frecuencia usado.
@end table

@enumerate
@item Si no se dan argumentos de salida, p.e.,
@example
bode(sys);
@end example
@code{bode} grafica los resultados en la pantalla. Etiquetas descriptivas se
muestran autom@'aticamente.

El hecho de no incluir un punto y coma al final, producir@'a basura que ser@'a 
mostrada a la pantalla. (@code{ans = []}).

@item Si el diagrama que se requiere es para un sistema @acronym{MIMO}, el 
valor de @var{mag} se establece en @math{||G(jw)||} o @math{||G(@code{exp}(jwT))||}
y la informaci@'on de los fase no se calcula.
@end enumerate
@end deftypefn
