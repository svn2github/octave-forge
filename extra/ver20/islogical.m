function a = islogical(m)
  a = all(all(m==1 | m==0));
