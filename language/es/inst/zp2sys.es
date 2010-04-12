md5="afab23a05d443a970e06305fcee16e27";rev="6944";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} zp2sys (@var{zer}, @var{pol}, @var{k}, @var{tsam}, @var{inname}, @var{outname})
Crea una estructura de datos del sistema de zero-pole data.

@strong{Entradas}
@table @var
@item   zer
Vector de ceros del sistema.
@item   pol
Vector de polos del sistema.
@item   k
Primer coeficiente escalar. 
@item   tsam
Per@'iodo de muestreo; por defecto: 0(Sistema continuo).
@item   inname
@itemx  outname
nombre de Entrada/salida de se@~{n}al (lista de caracteres).
@end table

@strong{Salidas}
@table @var
@item sys
Estructura de datos del sistema.
@end table

@strong{Ejemplo}
@example
octave:1> sys=zp2sys([1 -1],[-2 -2 0],1);
octave:2> sysout(sys)
Input(s)
        1: u_1
Output(s):
        1: y_1
zero-pole form:
1 (s - 1) (s + 1)
-----------------
s (s + 2) (s + 2)
@end example
@end deftypefn