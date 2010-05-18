function a = power (a, b)

  if (b == -1 && isa (a, "quaternion") && isscalar (a.w))
    a = inv (a);
  else
    error ("quaternion: power: case not implemeted");
  endif

  ## TODO: - q1 .^ q2
  ##       - arrays

endfunction