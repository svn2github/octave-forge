mysql


db=mysql_init();

res=mysql_real_connect(db,"localhost","root","secret","testdb");
if (swig_this(res)!=swig_this(db))
  error("connect to db failed");
endif


mysql_get_client_info()
mysql_get_client_version()
mysql_get_host_info(db)
mysql_get_proto_info(db)
mysql_get_server_info(db)
mysql_get_server_version(db)
mysql_get_ssl_cipher(db)
mysql_info(db)
mysql_thread_id(db)
mysql_insert_id(db)


if (mysql_query(db,"select 2,4,8;"))
  error("query failed: %i %s",mysql_errno(db),mysql_error(db));
endif


res=mysql_store_result(db);

f1=mysql_fetch_field_direct(res,0);
f2=mysql_fetch_field_direct(res,1);

nc=int32(mysql_field_count(db))
nr=int32(mysql_num_rows(res))

c=cell(nr,nc);
for i=0:nr-1,
  r=mysql_fetch_row(res);
  for j=0:nc-1,
    c{i+1,j+1}=r(j);
  endfor
endfor
c

mysql_free_result(res)

mysql_close(db)
