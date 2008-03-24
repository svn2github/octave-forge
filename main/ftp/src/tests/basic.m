ftpobj

f=ftp("ftp.gnu.org")

f.dir()
f.ls()
f.cd("gnu")
f.ls()


f.cd("gcc/gcc-4.0.4")

mget(f,"gcc-objc-4.0.4.tar.bz2","gcc-g++-4.0.4.tar.gz.sig",".")

assert(stat("gcc-objc-4.0.4.tar.bz2").size==242757);
assert(stat("gcc-g++-4.0.4.tar.gz.sig").size==65);

unlink("gcc-objc-4.0.4.tar.bz2");
unlink("gcc-g++-4.0.4.tar.gz.sig");




