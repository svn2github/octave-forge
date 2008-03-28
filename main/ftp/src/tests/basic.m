ftpobj

f=ftp("ftp.gnu.org")

f.dir()
f.ls()
f.cd("gnu")
f.ls()

f.cd("gcc/gcc-4.0.4")
f.cd("../..");
f.cd("..");

mget(f,"MISSING-FILES","MISSING-FILES.README",".")

assert(stat("MISSING-FILES").size==17864);
assert(stat("MISSING-FILES.README").size==4178);

unlink("MISSING-FILES");
unlink("MISSING-FILES.README");




