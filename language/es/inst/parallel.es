md5="f4d050bee9f6804e0dc8ef2a10d49e47";rev="6377";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{ksys} =} parallel (@var{asys}, @var{bsys})
Forma la conexi@'on paralela de dos sistemas.

@example
@group
             --------------------
             |      --------    |
    u  ----->|----> | asys |--->|----> y1
        |    |      --------    |
        |    |      --------    |
        |--->|----> | bsys |--->|----> y2
             |      --------    |
             --------------------
                  ksys
@end group
@end example
@end deftypefn
