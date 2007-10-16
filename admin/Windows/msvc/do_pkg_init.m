mkdir (pkg ("prefix"));
global_list = pkg ("global_list");
global_packages = pkg ("rebuild");

for k = 1:length (global_packages)
  if (strcmp (global_packages{k}.name, "jhandles"))
    global_packages = {global_packages{1:k-1}, global_packages{k+1:end}, global_packages{k}};
    save (global_list, "global_packages");
    break;
  endif
endfor
