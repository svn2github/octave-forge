function a = mpower (a, b)

  if (b == -1 && isa (a, "quaternion") && isscalar (a.w))
    a = inv (a);
  else
    error ("quaternion: mpower: case not implemeted");
  endif

endfunction