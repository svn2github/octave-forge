postgres

default_db(postgres_db("host=localhost dbname=testdb user=testuser password='secret' "));
try
  sql("drop table some_table;");
catch
end_try_catch
sql("create table some_table (id int4,str varchar);");
sql("insert into some_table (id,str) values (1,'a');");
sql("insert into some_table (id,str) values (2,'b');");
sql("insert into some_table (id,str) values (3,'c');");
sql("insert into some_table (id,str) values (4,'d');");
a=sql("select * from some_table;")
assert(a{1,1}==1);
assert(a{2,1}==2);
assert(a{3,1}==3);
assert(a{4,1}==4);
assert(strcmp(a{1,2},"a"));
assert(strcmp(a{2,2},"b"));
assert(strcmp(a{3,2},"c"));
assert(strcmp(a{4,2},"d"));
