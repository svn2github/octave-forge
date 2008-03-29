source("../PKG_ADD");

f=ftp("ftp.gnu.org")

dir(f)
ls(f)
cd(f,"gnu")
ls(f)

cd(f,"gcc/gcc-4.0.4")
cd(f,"../..");
cd(f,"..");

mget(f,"MISSING-FILES","MISSING-FILES.README",".")

assert(stat("MISSING-FILES").size==17864);
assert(stat("MISSING-FILES.README").size==4178);

unlink("MISSING-FILES");
unlink("MISSING-FILES.README");
