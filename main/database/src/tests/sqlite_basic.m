sqlite3

system("rm -f data.db");
[res,db]=sqlite3_open("data.db");
[res,stmt]=sqlite3_prepare(db,"create table some_table (id int4,str varchar);");
res=sqlite3_step(stmt);
sqlite3_finalize(stmt);
sqlite3_close(db);
