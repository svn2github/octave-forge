try
  sql("select 2;");
  error
catch
end_try_catch

sqlite3;

sql(sqlite3_db("data.db"),"select 2;");

default_db(sqlite3_db("data.db"));
sql("select 2;");




