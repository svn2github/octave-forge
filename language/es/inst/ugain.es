md5="c2a49e729a6087f08941af1b2f4e72af";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} ugain (@var{n})
Crea un sistema con ganacia unitaria, sin estados. Este sistema trivial 
es necesario algunas veces para crear sistemas arbitráriamente complejos 
a partir de sistemas sencillos con el comando @command{buildssic}. Se debe 
tener precausión con la formación de sistemas muestreo puesto que el 
comando @command{ugain} no contiene periodo de muestreo.
@seealso{hinfdemo, jet707}
@end deftypefn
