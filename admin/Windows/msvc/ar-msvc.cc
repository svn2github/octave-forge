/*
 * Copyright (C) 2007 Michael Goffioul
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <list>
#include <string>
#include <vector>

using namespace std;

static bool verbose = true;

void usage (int code)
{
  cerr << "Usage: ar-msvc [OPTIONS]" << endl << endl;

  cerr << "ar-msvc is a wrapper around Microsoft's lib.exe. It translates parameters" << endl;
  cerr << "that Unix ar's understand to parameters that lib undertsand." << endl;

  exit (code);
}

inline bool starts_with(const string& s, const string& prefix)
{
	return (s.length() >= prefix.length() && s.find(prefix) == 0);
}

inline bool ends_with(const string& s, const string& suffix)
{
	return (s.length() >= suffix.length() && s.rfind(suffix) == s.length()-suffix.length());
}

int do_system (const string& cmd)
{
  if (verbose)
    cerr << "Running: " << cmd << endl;

  return system(cmd.c_str());
}

static string get_line (FILE *fp)
{
  static vector<char> buf(100);
  int idx = 0;
  char c;

  while (1)
    {
      c = (char)fgetc(fp);
      if (c == '\n' || c == EOF)
	break;
      if (buf.size() <= idx)
	buf.resize(buf.size() + 100);
      buf[idx++] = c;
    }
  if (idx == 0)
    return string("");
  else
    {
      if (buf[idx-1] == '\r')
	idx--;

      return string(&buf[0], idx);
    }
}

list<string> do_system_with_output (const string& cmd)
{
  if (verbose)
    cerr << "Running: " << cmd << endl;

  FILE *fd = _popen (cmd.c_str (), "r");
  list<string> output;
  string line;

  if (fd == NULL)
    {
      cerr << "Cannot execute: " << cmd << endl;
      exit (-1);
    }

  while (! feof (fd))
    {
      line = get_line (fd);
      output.push_back (line);
    }

  return output;
}

string do_system_with_output_1 (const string& cmd)
{
  list<string> output = do_system_with_output (cmd);

  return (output.size () > 0 ? output.front () : string ());
}

int main (int argc, char **argv)
{
  string cmd, cmdopts, archive_file, convert;
  list<string> files;
  int offset = 1;

  if (argc <= offset)
    usage (-1);

  if (strcmp (argv[offset], "--cygwin") == 0)
    {
      convert = "cygwin";
      offset++;
    }

  if (argc <= offset)
    usage (-1);

  cmd = argv[offset++];
  while (cmd.length () > 0 && cmd[0] == '-')
    cmd.erase (0, 1);

  if (cmd == "version")
    {
      cerr << "ar-msvc 0.1" << endl;
      cerr << "" << endl;
      cerr << "Copyright 2006 Michael Goffioul" << endl;
      cerr << "This is free software; see the source for copying conditions.  There is NO" << endl;
      cerr << "waranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE." << endl;

      exit (0);
    }
  else if (cmd == "help" || cmd == "h")
    {
      usage (0);
    }
  else if (starts_with (cmd, "r") || starts_with (cmd, "cr"))
    cmd = "replace";
  else if (starts_with (cmd, "t"))
    cmd = "list";
  else if (starts_with (cmd, "x"))
    cmd = "extract";
  else
    {
      cerr << "Unsupported command flag: " << cmd << endl;
      exit (-1);
    }

  while (offset < argc)
    {
      if (archive_file.empty ())
	{
	  archive_file = argv[offset];

	  if (ends_with (archive_file, ".a"))
	    archive_file.erase (archive_file.length () - 2).append (".lib");

	  int pos = archive_file.find_last_of ("\\/");

	  if (pos != string::npos)
	    pos = -1;
	  
	  if (archive_file.substr (pos+1, 3) == "lib")
	    archive_file.replace (pos+1, 3, "");
	}
      else
	files.push_back (argv[offset]);

      offset++;
    }

  if (! convert.empty ())
    {
      if (convert == "cygwin")
	archive_file = do_system_with_output_1 ("cygpath -m " + archive_file);
    }

  if (cmd == "extract")
    {
      if (files.size () == 0)
	files = do_system_with_output ("lib -nologo -list " + archive_file);

      for (list<string>::const_iterator it = files.begin (); it != files.end (); ++it)
	{
	  string output = *it;
	  int pos = output.find_last_of ("\\/");

	  if (pos != string::npos)
	    output.erase (0, pos+1);

	  do_system ("lib -nologo -extract:" + (*it) + " -out:" + output + " " + archive_file);
	}
    }
}
