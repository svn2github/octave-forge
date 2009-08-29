md5="3b8e8aae17395333ec00bf45b8ef2ef3";rev="6166";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {[@var{err}, @var{msg}] =} kill (@var{pid}, @var{sig})
Envia una se@~{n}al @var{sig} al proceso @var{pid}.

Si @var{pid} es positivo, la se@~{n}al @var{sig} se envia a @var{pid}.

Si @var{pid} es 0, la se@~{n}al @var{sig} se envia a cada proceso dentro del 
grupo de procesos del proceso actual.

Si @var{pid} es -1, se envia la se@~{n}al @var{sig} a cada proceso 
excepto el proceso 1.

Si @var{pid} es menor que -1, la se@~{n}al @var{sig} se envia a cada 
proceso en el grupo de procesos @var{-pid}.

Si @var{sig} es 0, no se envia ninguna se envia ninguna se@~{n}al, sin embargo la 
verificaci@'on de errores se sigue realizando.

La funci@'on kill retorna 0 si es exitosa y -1 en cualquier otro caso.
@end deftypefn
