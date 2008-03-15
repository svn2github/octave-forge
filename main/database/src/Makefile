sinclude Makeconf

.PHONY: clean check

all: sqlite3.oct postgres.oct mysql.oct odbc.oct

sqlite3.oct: sqlite3.i sqlite3_filtered.h
	$(SWIG) -octave -c++ -o sqlite3_wrap.cpp sqlite3.i
	$(MKOCTFILE) -o sqlite3.oct -lsqlite3 sqlite3_wrap.cpp

postgres.oct: postgres.i libpq-fe_filtered.h
	$(SWIG) -octave -c++ -o postgres_wrap.cpp postgres.i
	$(MKOCTFILE) -o postgres.oct postgres_wrap.cpp -lpq

mysql.oct: mysql.i mysql_filtered.h
	$(SWIG) -octave -c++ -o mysql_wrap.cpp mysql.i
	$(MKOCTFILE) -o mysql.oct -lmysqlclient mysql_wrap.cpp

odbc.oct: odbc.i sql_filtered.h sqltypes_filtered.h sqlext_filtered.h
	$(SWIG) -octave -c++ -o odbc_wrap.cpp odbc.i
	$(MKOCTFILE) -o odbc.oct -lodbc odbc_wrap.cpp

clean:
	-$(RM) *.o octave-core core *.oct *~ *_wrap.cpp

TEST_CASES =   \
	helpers \
	mysql_basic \
	mysql_empty \
	mysql_high \
	odbc_basic  \
	odbc_empty \
	odbc_high \
	postgres_basic  \
	postgres_empty  \
	sqlite_basic  \
	sqlite_empty  \
	sqlite_high

NOT_BROKEN_TEST_CASES = $(TEST_CASES:=.test)
.PHONY: check
check: $(NOT_BROKEN_TEST_CASES)
%.test:
	octave -q tests/$*.m > /dev/null

