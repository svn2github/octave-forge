/* Copyright (C) 2005 Stefan van der Walt <stefan@sun.ac.za>

   Redistribution and use in source  and binary forms, with or without
   modification, are permitted  provided that the following conditions
   are met:

   1. Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.

   2. Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
  IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
  IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

#include <octave/oct.h>
#include <octave/Cell.h>
#include <octave/quit.h>

#include <string>
#include <sstream>
#include <iostream>
#include <fstream>

#define BUFFER_SIZE 4096

/*
 * Manage all information relevant to the texfile read.  This includes
 * file I/O and the format descriptions of the different fields.
 */
class TextFile
{
public:
    TextFile(std::string filename)
	: _lines(0)
    {
	this->filename = filename;
	open();
    }

    ~TextFile()
    {
	if (data.is_open()) {
	    data.close();
	}
    }

    bool
    open()
    {
	data.open(filename.c_str());
	if (!data) {
	    error("textread: couldn't open data file %s", filename.c_str());
	}
    }

    void
    close()
    {
	data.close();
    }

    void
    ignore_whitespace()
    {
	data >> std::skipws;
    }

    long unsigned int
    lines()
    {
	if (_lines == 0) {

	    std::ifstream tmpdata(filename.c_str());
	    if (!tmpdata) { 
		warning("textread: couldn't open file for line counting");
		return 0;
	    }

	    char buf[BUFFER_SIZE];
	    while (!tmpdata.eof()) {
		tmpdata.getline(buf, 4096);
		if (std::string(buf).length() != 0) {
		    _lines++;
		}
	    }
	    
	    tmpdata.close();
	}

	return _lines;
    }
    
    template <typename container_type, typename column_type>
    void
    set_container_data(std::vector<container_type> &v, const unsigned int &field, const long unsigned int &record)
    {
	column_type p;
	line >> p;

	if (!data) {
	    return;
	}
	
	v[field](0, record) = p;
    }

    void
    skip_column()
    {
	std::vector<Cell> a;
	Cell c = Cell(1,1);
	a.push_back(c);
	set_container_data<Cell, std::string>(a, 0, 0);
    }
    
    void
    readline()
    {
	data.getline(buffer, 4096);
	if (std::string(buffer).length() != 0) {
	    line.str(buffer);
	    line.clear();
	}
    }

    bool
    is_valid() {
	return data ? true : false;
    }

    void
    set_format(const std::string &fmt) {
	std::istringstream format_s(fmt);
	while (format_s && !format_s.eof()) {
	    std::string p;
	    format_s >> p;
	    columns.push_back(p);
	}
    }

    /// Column format descriptor
    std::vector<std::string> columns;

private:
    std::string filename;
    std::ifstream data;

    char buffer[BUFFER_SIZE];
    std::istringstream line;

    unsigned long int _lines;
};


DEFUN_DLD(textread, args, ,
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[@var{a}, @var{b}, @var{c}, ...] =} textread (@var{filename}, @var{format}[, @var{N}])\n\
\n\
Read data from the columns of a text file.\n\
\n\
Columns containing strings are returned as cell-arrays, while numeric values\n\
are returned as matrices.\n\
\n\
The string @var{format} describes the different columns of the text file and\n\
is repeated @var{N} times.  It may continue the following specifiers:\n\
\n\
@table @code\n\
@item %s\n\
for a string,\n\
\n\
@item %d\n\
for a double, floating-point or integer number and\n\
\n\
@item %*\n\
to ignore a column.\n\
@end table\n\
\n\
For example, the textfile containing\n\
\n\
@example\n\
@group\n\
Bunny Bugs   5.5\n\
Duck Daffy  -7.5e-5\n\
Penguin Tux   6\n\
@end group\n\
@end example\n\
\n\
can be read using\n\
\n\
@example\n\
@code{[a,b,c] = textread(\"test.txt\", \"%s %s %d\").}\n\
@end example\n\
\n\
@end deftypefn\n\
@seealso{load, dlmread, fscanf}")
{
    octave_value_list retval;

    if ((args.length() < 2) || (args.length() > 3)) {
	print_usage ();
	return retval;
    }

    std::string filename = args(0).string_value();
    std::string format = args(1).string_value();
    int repeat = 0;
    if (args.length() == 3) {
	repeat = args(2).int_value();
    }
    if (error_state) {
	error("Invalid argument specified");
	print_usage ();
	return retval;
    }

    TextFile input(filename.c_str());
    if (!input.is_valid()) {
	return retval;
    }

    format += " ";
    std::string repeated_fmt(format);
    for (int i = 0; i < (repeat-1); i++) {
	repeated_fmt += format;
    }

    input.set_format(repeated_fmt);    
    input.ignore_whitespace();

    long unsigned int nr_rows = input.lines();
    if (nr_rows == 0) {
	return retval;
    }

    std::vector<Matrix> matrix_output;
    std::vector<Cell> cell_output;

    for (int i = 0; i < input.columns.size(); i++) {
	if ((input.columns[i] == "%d") || (input.columns[i] == "%f") || (input.columns[i] == "%u")) {
	    // Storage matrix
	    matrix_output.push_back(Matrix(1, nr_rows, 0));

	    // Placeholder
	    cell_output.push_back(Cell());
	}
	else if (input.columns[i] == "%s") {
	    cell_output.push_back(Cell(1, nr_rows));
	    matrix_output.push_back(Matrix());
	}
	else {
	    cell_output.push_back(Cell());
	    matrix_output.push_back(Matrix());
	}
    }

    std::string s;
    double d;
    char buf[1024];
    long unsigned int row = 0;
    try 
	{
	    while ((row < nr_rows) && input.is_valid()) {
		input.readline();

		for (unsigned int i = 0; i < input.columns.size(); i++) {
		    OCTAVE_QUIT;

		    if ((input.columns[i] == "%d") || (input.columns[i] == "%f") || (input.columns[i] == "%u")) {
			input.set_container_data<Matrix, double>(matrix_output, i,  row);
		    } else if (input.columns[i] == "%s") {
			input.set_container_data<Cell, std::string>(cell_output, i, row);
		    } else {
			input.skip_column();
		    }
		}
		row++;
	    }
	}
    catch (std::exception e)
	{
	    error("textread: cannot read from %s (%s)", filename.c_str(), e.what());
	    return retval;
	}

    dim_vector dim(1, input.lines());
    for (int i = 0; i < input.columns.size(); i++) {
	long unsigned int cl = cell_output[i].length();
	long unsigned int ml = matrix_output[i].length();

	if ((cl == 0) && (ml == 0)) {
	    continue;
	}
	else if (cl == 0) {
	    matrix_output[i].resize(1, input.lines());
	    retval.append(octave_value(matrix_output[i].transpose()));
	} else {
	    cell_output[i].resize(dim);
	    retval.append(octave_value(cell_output[i].transpose()));
	}
    }

    input.close();

    return retval;
}
