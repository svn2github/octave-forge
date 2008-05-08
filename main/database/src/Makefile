sinclude Makeconf

# disable optimizations since gcc consumes too much memory
# this line can be removed
MKOCTFILE:=CXXFLAGS=-O0 $(MKOCTFILE)

.PHONY: clean check

OCTFILES=
ifdef HAVE_POSTGRES
OCTFILES+=postgres.oct
endif
ifdef HAVE_MYSQL
OCTFILES+=mysql.oct
endif
ifdef HAVE_SQLITE3
OCTFILES+=sqlite3.oct
endif
ifdef HAVE_ODBC
OCTFILES+=odbc.oct
endif

all: $(OCTFILES)

sqlite3.oct: sqlite3_wrap.cpp sqlite3_filtered.h
	$(MKOCTFILE) -o sqlite3.oct -lsqlite3 sqlite3_wrap.cpp

postgres.oct: postgres_wrap.cpp libpq-fe_filtered.h
	$(MKOCTFILE) -o postgres.oct postgres_wrap.cpp -lpq

mysql.oct: mysql_wrap.cpp mysql_filtered.h
	$(MKOCTFILE) -o mysql.oct -lmysqlclient mysql_wrap.cpp

odbc.oct: odbc_wrap.cpp sql_filtered.h sqltypes_filtered.h sqlext_filtered.h
	$(MKOCTFILE) -o odbc.oct -lodbc odbc_wrap.cpp

ifdef SWIG
sqlite3_wrap.cpp: sqlite3.i
	$(SWIG) -octave -c++ -o sqlite3_wrap.cpp sqlite3.i

postgres_wrap.cpp: postgres.i
	$(SWIG) -octave -c++ -o postgres_wrap.cpp postgres.i

mysql_wrap.cpp: mysql.i
	$(SWIG) -octave -c++ -o mysql_wrap.cpp mysql.i

odbc_wrap.cpp: odbc.i
	$(SWIG) -octave -c++ -o odbc_wrap.cpp odbc.i
endif

clean:
	-$(RM) *.o octave-core core *.oct *~
ifdef SWIG
	rm -f sqlite3_wrap.cpp postgres_wrap.cpp mysql_wrap.cpp odbc_wrap.cpp
endif

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

