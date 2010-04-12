md5="1edad4ff3c44972b21cdbc1e688e6768";rev="6893";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} zp (@var{zer}, @var{pol}, @var{k}, @var{tsam}, @var{inname}, @var{outname})
Crea la estructura de datos del sistema de zero-pole

@strong{Entradas}
@table @var
@item   zer
vector de ceros del sistema
@item   pol
vector de polos del sistema
@item   k
coeficiente principal escalar
@item   tsam
per@'iodo de muestreo. por defecto: 0 (sistema continuo)
@item   inname
@itemx  outname
entrada/salida nombres de se@~{n}ales (listas de cadenas de caracteres)
@end table

@strong{Salidas}
sys: estructura de datos del sistema

@strong{Ejemplo}
@example
octave:1> sys=zp([1 -1],[-2 -2 0],1);
octave:2> sysout(sys)
Entrada(s)
        1: u_1
Salida(s):
        1: y_1
zero-pole de:
1 (s - 1) (s + 1)
-----------------
s (s + 2) (s + 2)
@end example
@end deftypefn