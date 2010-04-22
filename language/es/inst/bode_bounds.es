md5="1a474f1fffe7cc3df665009b251208b8";rev="7224";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{wmin}, @var{wmax}] =} bode_bounds (@var{zer}, @var{pol}, @var{dflg}, @var{tsam})
Obtiene el rango predeterminado de frecuencias sobre la base de las 
frecuencias de corte de polos y ceros del sistema.
El rango de frecuencias está el intervalo
@iftex
@tex
$ [ 10^{w_{min}}, 10^{w_{max}} ] $
@end tex
@end iftex
@ifinfo
[10^@var{wmin}, 10^@var{wmax}]
@end ifinfo

Esta función es usada internamente en @command{__freqresp__} (@command{bode}, @command{nyquist})
@end deftypefn
