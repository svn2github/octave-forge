## Fake conversion to logical values.  Use 2.1.x for proper logical support.
function l=logical(a)
  l = (a != 0);
