md5="daeb248135b21db41da5a1de073d64ae";rev="6466";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{xinf}, @var{x_ha_err}] =} hinfsyn_ric (@var{a}, @var{bb}, @var{c1}, @var{d1dot}, @var{r}, @var{ptol})

Forma 

@example
xx = ([bb; -c1'*d1dot]/r) * [d1dot'*c1 bb'];
Ha = [a 0*a; -c1'*c1 - a'] - xx;
@end example

y resuelve la ecuaci@'on de Riccati asociada.

El c@'odigo de error @var{x_ha_err} indica una de las siguientes 
condiciones:

@table @asis
@item 0
Exitosa
@item 1
@var{xinf} tiene valores propios imaginarios
@item 2
@var{hx} no Hamiltoniana
@item 3
@var{xinf} tiene valores propios infinitos (desbordamiento num@'erico)
@item 4
@var{xinf} no sim@'etrica
@item 5
@var{xinf} no positiva definida
@item 6
@var{r} es singular
@end table
@end deftypefn
