## Fake test if m is a logical value.  Returns true if all elements are 
## either 0 or 1.
function a = islogical(m)
  a = all(all(m==1 | m==0));
