## Have to copy the libaries to the right place
function post_install (desc)
  if (exist("src", "dir"))
    ## make install
    [status, output] = system(["export INSTALLDIR=" desc.dir "; make install -C  src"]);
    if (status != 0)
      error("'make install' returned the following error: %s\n", output);
    endif
  endif
endfunction
