-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} warning (@var{template}, @dots{})
@deftypefnx {Funci@'on incorporada} {} warning (@var{id}, @var{template}, @dots{})
Formato de los argumentos opcionales bajo el control de la cadena de
plantilla @var{template} utilizando las mismas normas que @code{printf}
familia de funciones (@pxref{Formatted Output}) e imprimir el mensaje 
resultante en @code{stderr}. El mensaje está precedido de la cadena de
caracteres @samp{warning: }. 
Usted debe usar esta función cuando desee para notificar al usuario de
una condición inusual, pero sólo cuando tenga sentido para su programa
para seguir adelante.

El identificador de mensaje opcional permite a los usuarios activar o
desactivar las advertencias marcadas por @var{id}. El identificador
especial @samp{"all"} se puede utilizar para establecer el estado de
todas las advertencias.

@deftypefnx {Funci@'on incorporada} {} warning ("on", @var{id})
@deftypefnx {Funci@'on incorporada} {} warning ("off", @var{id})
@deftypefnx {Funci@'on incorporada} {} warning ("error", @var{id})
@deftypefnx {Funci@'on incorporada} {} warning ("query", @var{id})
Establecer o consultar el estado de una advertencia en particular
usando el identificador @var{id}. Si el identificador se omite,
el valor de @samp{"all"} se supone. Si se establece el estado de 
una advertencia para @samp{"error"}, la advertencia nombrada por
@var{id} se maneja como si se tratara de un error en su lugar.
@seealso{warning_ids}
@end deftypefn
