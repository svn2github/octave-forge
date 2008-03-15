postgres

conn=PQconnectdb("host=localhost dbname=testdb user=testuser password='secret' ");
assert(PQstatus(conn)==CONNECTION_OK);

PQerrorMessage(conn)
PQconndefaults()

PQdb(conn)
PQuser(conn)
PQpass(conn)
PQhost(conn)
PQport(conn)
PQtty(conn)
PQoptions(conn)
PQstatus(conn)
PQtransactionStatus(conn)

# create user testuser with superuser password 'secret';

PQparameterStatus(conn,"client_encoding")
PQprotocolVersion(conn)
PQserverVersion(conn)
PQerrorMessage(conn)
PQsocket(conn)
PQbackendPID(conn)
PQgetssl(conn)

r1=PQexec(conn, "create table some_table (id int4,str varchar);")
PQresStatus(PQresultStatus(r1))
PQresultErrorMessage(r1)

PQcmdStatus(r1)
PQcmdTuples(r1)
PQoidValue(r1)

PQclear(r1);

PQclear(PQexec(conn, "insert into some_table (id,str) values (1,'a');"));
PQclear(PQexec(conn, "insert into some_table (id,str) values (2,'b');"));
PQclear(PQexec(conn, "insert into some_table (id,str) values (3,'c');"));
PQclear(PQexec(conn, "insert into some_table (id,str) values (4,'d');"));
PQclear(PQexec(conn, "insert into some_table (id,str) values (5,'e');"));

r2=PQexec(conn, "select * from some_table;");

PQntuples(r2)
PQnfields(r2)
PQfname(r2,0)
PQfname(r2,1)
assert(strcmp(PQfname(r2,0),"id"));
assert(strcmp(PQfname(r2,1),"str"));

assert(PQfnumber(r2,"str")==1);
assert(PQfnumber(r2,"id")==0);
PQftable(r2,0)
PQftablecol(r2,0)
PQftablecol(r2,1)
PQfformat(r2,0)
PQfformat(r2,1)
PQftype(r2,0)
PQftype(r2,1)
PQfmod(r2,0)
PQfmod(r2,1)
PQfsize(r2,0)
PQbinaryTuples(r2)

c=cell(PQntuples(r2),PQnfields(r2));
for i=0:PQntuples(r2)-1,
  for j=0:PQnfields(r2)-1,
    if (!PQgetisnull(r2,3,0))
      c{i+1,j+1}=PQgetvalue(r2,i,j);
    endif
  endfor
endfor

PQgetisnull(r2,3,0)
PQgetlength(r2,0,1)

PQclear(r2);

PQfinish(conn);
