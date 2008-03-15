odbc

[res,env]=SQLAllocEnv();
assert(res==SQL_SUCCESS);
[res,conn]=SQLAllocConnect(env);
assert(res==SQL_SUCCESS);

res=SQLConnect(conn,"testdb23232","testuser","secret")
[res,state,errno,errmsg]=SQLGetDiagRec(SQL_HANDLE_DBC,conn,1)
SQL_HANDLE_ENV, SQL_HANDLE_DBC, SQL_HANDLE_STMT, SQL_HANDLE_DESC

[res,conn]=SQLAllocConnect(env)
res=SQLConnect(conn,"testdb","testuser","secret")
assert(res==SQL_SUCCESS);

[res,stmt]=SQLAllocStmt(conn)
res=SQLExecDirect(stmt,"select * from that_table;")
[res,state,errno,errmsg]=SQLGetDiagRec(SQL_HANDLE_STMT,stmt,1)

[res,stmt]=SQLAllocStmt(conn)
res=SQLExecDirect(stmt,"select * from some_table;")
[res,nr]=SQLRowCount(stmt)
[res,nc]=SQLNumResultCols(stmt)

[res,name,ctype,len]=SQLDescribeCol(stmt,1)
[res,name,ctype,len]=SQLDescribeCol(stmt,2)

res=SQLFetch(stmt)

[res,val,len_or_ind]=SQLGetData(stmt,1)
[res,val,len_or_ind]=SQLGetData(stmt,2)

# loop on SQLFetch until res==SQL_NO_DATA
SQL_NO_DATA

SQLFreeStmt(stmt,0);

res=SQLDisconnect(conn);
SQLFreeConnect(conn);
SQLFreeEnv(env);

