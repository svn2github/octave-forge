/*
 * cc-msvc
 * This code is a C translation of the cccl script from Geoffrey Wossum
 * (http://cccl.sourceforge.net), with minor modifications and support for
 * additional compilation flags. This tool is primarily intended to compile
 * Octave source code with MSVC compiler.
 *
 * Copyright (C) 2006 Michael Goffioul
 * 
 * cccl
 * Wrapper around MS's cl.exe and link.exe to make them act more like
 * Unix cc and ld
 * 
 * Copyright (C) 2000-2003 Geoffrey Wossum (gwossum@acm.org)
 *
 * =========================================================================
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
 * =========================================================================
 *
 * Compile this file with "cl -EHs -O2 cc-msvc.cc" and install it into
 * your PATH environment variable.
 * 
 */

#include <iostream>
#include <string>
#include <vector>
#include <list>
#include <io.h>
#include <stdio.h>

#ifdef _MSC_VER
#define popen _popen
#define pclose _pclose
#endif

using namespace std;

static string usage_msg = 
"Usage: cc-msvc [OPTIONS]\n"
"\n"
"cc-msvc is a wrapper around Microsoft's cl.exe and link.exe.  It translates\n"
"parameters that Unix cc's and ld's understand to parameters that cl and link\n"
"understand.";
static string version_msg =
"cc-msvc 0.1\n"
"\n"
"Copyright 2006 Michael Goffioul\n"
"This is free software; see the source for copying conditions.  There is NO\n"
"waranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.\n";

inline bool starts_with(const string& s, const string& prefix)
{
	return (s.length() >= prefix.length() && s.find(prefix) == 0);
}

inline bool ends_with(const string& s, const string& suffix)
{
	return (s.length() >= suffix.length() && s.rfind(suffix) == s.length()-suffix.length());
}

static string get_line(FILE *fp)
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
		return string(&buf[0], idx);
}

static string process_depend(const string& s)
{
	string result;
	for (int i=0; i<s.length(); i++)
	{
		if (s[i] == ' ')
			result += "\\ ";
		else if (s[i] == '\\' && i < s.length()-1 && s[i+1] == '\\')
		{
			result.push_back('/');
			i++;
		}
		else
			result.push_back(s[i]);
	}
	return result;
}

static string quote_path(const string& s)
{
	if (s.find(' ') != string::npos)
		return "\"" + s + "\"";
	return s;
}

static string quote_quotes(const string& s)
{
	string result;

	if (s.find('"') != string::npos)
	{
		for (int i=0; i<s.length(); i++)
			if (s[i] == '"')
				result += "\\\"";
			else
				result.push_back(s[i]);
	}
	else
		result = s;

	if (result.find_first_of("&<>()@^|") != string::npos)
		result = "\"" + result + "\"";

	return result;
}

static bool read_stdin(const char *filename)
{
	char buf[1024];
	int n;
	FILE *fout = fopen(filename, "wb");

	if (fout == NULL)
	{
		cerr << filename << ": cannot open file for writing" << endl;
		return false;
	}
	while ((n = fread(buf, 1, 1024, stdin)) > 0)
		fwrite(buf, 1, n, fout);
	fclose(fout);
	return true;
}

int main(int argc, char **argv)
{
	string clopt, linkopt, cllinkopt, sourcefile, objectfile, optarg, prog, exefile;
	bool gotparam, dodepend, exeoutput, doshared, debug = false, read_from_stdin;

	prog = "cl";
	clopt = "-nologo";
	linkopt = "-nologo";
	cllinkopt = "";
	sourcefile = "";
	objectfile = "";
	gotparam = false;
	dodepend = false;
	exeoutput = true;
	exefile = "";
	doshared = false;
	read_from_stdin = false;

	if (argc == 1)
	{
		cout << usage_msg << endl;
		return 1;
	}

	for (int i=1; i<argc; i++)
	{
		string arg = argv[i];
		size_t pos;

		optarg = "";
		gotparam = true;

		if (!starts_with(arg, "-D") && (pos=arg.find('=')) != string::npos)
		{
			optarg = arg.substr(pos+1);
		}

		if (arg == "--version" || arg == "-V")
		{
			cout << version_msg << endl;
			return 0;
		}
		else if (arg == "-M")
		{
			dodepend = true;
			if (!exeoutput)
				clopt += " -E";
			else
			{
				exeoutput = false;
				clopt += " -E -c";
			}
		}
		else if (arg == "-P")
		{
			clopt += " -EP";
		}
		else if (arg == "-ansi")
		{
			clopt += " -Za";
		}
		else if (arg == "-c")
		{
			if (!dodepend)
			{
				clopt += " -c";
				exeoutput = false;
			}
		}
		else if (arg == "-g" || (starts_with(arg, "-g") && arg.length() == 3 && arg[2] >= '0' && arg[2] <= '9'))
		{
			clopt += " -Zi";
			linkopt += " -debug";
		}
		else if (arg == "-d")
		{
			debug = true;
		}
		else if (arg == "-shared")
		{
			clopt += " -LD";
			linkopt += " -DLL";
			doshared = true;
		}
		else if (arg == "-mwindows")
		{
			linkopt += " -subsystem:windows";
		}
		else if (arg == "-O2" || arg == "-MD")
		{
			// do not pass those to the linker
			clopt += (" " + arg);
		}
		else if (starts_with(arg, "-I"))
		{
			string path = arg.substr(2);
			clopt += " -I" + quote_path(path);
		}
		else if (starts_with(arg, "-L"))
		{
			string path = arg.substr(2);
			linkopt += " -LIBPATH:" + quote_path(path);
			cllinkopt += " -LIBPATH:" + quote_path(path);
		}
		else if (starts_with(arg, "-l"))
		{
			string libname = arg.substr(2) + ".lib";
			if (sourcefile.empty())
				clopt += " " + libname;
			else
				cllinkopt += " " + libname;
			linkopt += " " + libname;
		}
		else if (starts_with(arg, "-Wl,"))
		{
			string flags = arg.substr(4);
			linkopt += " " + flags;
			cllinkopt += " " + flags;
		}
		else if (arg == "-Werror")
		{
			clopt += " -WX";
		}
		else if (arg == "-Wall")
		{
			//clopt += " -Wall";
		}
		else if (arg == "-m386" || arg == "-m486" || arg == "-mpentium" ||
			 arg == "-mpentiumpro" || arg == "-pedantic" || starts_with(arg, "-W") ||
			 arg == "-fPIC")
		{
			// ignore
		}
		else if (arg == "-o")
		{
			if (i < argc-1)
			{
				arg = argv[++i];
				if (ends_with(arg, ".o") || ends_with(arg, ".obj"))
				{
					clopt += " -Fo" + quote_path(arg);
					objectfile = arg;
				}
				else if (ends_with(arg, ".exe") || ends_with(arg, ".dll") || ends_with(arg, ".oct")
					 || ends_with(arg, ".mex"))
				{
					clopt += " -Fe" + quote_path(arg);
					linkopt += " -out:" + quote_path(arg);
					exefile = arg;
				}
				else
				{
					cerr << "WARNING: unrecognized output file type " << arg << ", assuming executable" << endl;
					arg += ".exe";
					clopt += " -Fe" + quote_path(arg);
					linkopt += " -out:" + quote_path(arg);
					exefile = arg;
				}
			}
			else
			{
				cerr << "ERROR: output file name missing" << endl;
				return 1;
			}
		}
		else if (ends_with(arg, ".cc") || ends_with(arg, ".cxx") || ends_with(arg, ".C"))
		{
			clopt += " -Tp" + quote_path(arg);
			sourcefile = arg;
		}
		else if (ends_with(arg, ".o") || ends_with(arg, ".obj") || ends_with(arg, ".a") ||
			 ends_with(arg, ".lib") || ends_with(arg, ".so"))
		{
			if (ends_with(arg, ".a"))
			{
				if (_access(arg.c_str(), 00) != 0)
				{
					string libarg;
					int pos1 = arg.rfind('/');

					if (pos1 != string::npos)
						libarg = arg.substr(pos1+1);
					else
						libarg = arg;
					if (starts_with(libarg, "lib"))
						libarg = libarg.substr(3);
					libarg = arg.substr(0, pos1+1) + libarg.substr(0, libarg.length()-1) + "lib";
					if (_access(libarg.c_str(), 00) == 0)
					{
						cerr << "WARNING: Converting " << arg << " into " << libarg << endl;
						arg = libarg;
					}
				}
			}

			if (sourcefile.empty())
			{
				linkopt += " " + quote_path(arg);
				prog = "link";
			}
			else
			{
				cllinkopt += " " + quote_path(arg);
			}
		}
		else if (ends_with(arg, ".c") || ends_with(arg, ".cpp"))
		{
			clopt += " " + quote_path(arg);
			sourcefile = arg;
		}
		else if (ends_with(arg, ".dll"))
		{
			// trying to link against a DLL: convert to .lib file, keeping the same basename
			string libarg = (" " + arg.substr(0, arg.length()-4) + ".lib");
			clopt += libarg;
			linkopt += libarg;
		}
		else if (arg == "-")
		{
			// read source file from stdin
			read_from_stdin = true;
		}
		else
		{
			clopt += " " + quote_quotes(arg);
			linkopt += " " + quote_quotes(arg);
			if (!optarg.empty())
			{
				clopt += "=" + quote_quotes(optarg);
				linkopt += "=" + quote_quotes(optarg);
			}
		}
	}

	if (dodepend && prog != "cl")
	{
		cerr << "ERROR: dependency generation only possible for source file" << endl;
		return 1;
	}

	if (read_from_stdin)
	{
		sourcefile = "cc-msvc-tmp.c";
		if (!read_stdin(sourcefile.c_str()))
		{
			unlink(sourcefile.c_str());
			return 1;
		}
		clopt += (" " + sourcefile);
	}

	if (!exeoutput && !sourcefile.empty() && objectfile.empty())
	{
		// use .o suffix by default
		int pos = sourcefile.rfind('.');
		if (pos == string::npos)
			objectfile = sourcefile + ".o";
		else
			objectfile = sourcefile.substr(0, pos) + ".o";
		pos = objectfile.rfind('/');
		if (pos != string::npos)
			objectfile = objectfile.substr(pos+1);
		clopt += " -Fo" + objectfile;
	}

	string opts;
	if (prog == "cl")
	{
		opts = clopt;
		if (!cllinkopt.empty())
			opts += " -link " + cllinkopt;
	}
	else
		opts = linkopt;

	if (dodepend)
	{
		FILE *fd;
		string cmd = prog + " " + opts, line;
		list<string> depend_list;

		if (objectfile.empty())
		{
			cerr << "ERROR: object file name missing and cannot be determined" << endl;
			return 1;
		}
		cout << objectfile << ":";

		fd = popen(cmd.c_str(), "r");
		if (fd == NULL)
		{
			cerr << "ERROR: cannot execute " << cmd << endl;
			return 1;
		}
		while (!feof(fd))
		{
			line = get_line(fd);
			if (starts_with(line, "#line"))
			{
				int pos1 = line.find('"'), pos2 = line.find('"', pos1+1);
				depend_list.push_back(process_depend(line.substr(pos1+1, pos2-pos1-1)));
			}
		}
		pclose(fd);

		depend_list.sort();
		depend_list.unique();
		for (list<string>::const_iterator it=depend_list.begin(); it!=depend_list.end(); ++it)
			cout << " \\" << endl << "  " << *it;
		cout << endl;
		return 0;
	}
	else
	{
		string cmd = prog + " " + opts;
		int cmdresult;

		if (debug)
			cout << cmd << endl;
		if ((cmdresult=system(cmd.c_str())) == 0 && exeoutput)
		{
			// auto-embed the manifest, if any
			if (exefile.empty())
			{
				if (!sourcefile.empty())
				{
					if (doshared)
						exefile = sourcefile + ".dll";
					else
						exefile = sourcefile + ".exe";
				}
				else
				{
					cerr << "ERROR: cannot determine the output executable file" << endl;
					return 1;
				}
			}

			if (_access((exefile + ".manifest").c_str(), 00) == 0)
			{
				cmd = "mt -nologo -outputresource:" + exefile + " -manifest " + exefile + ".manifest";

				if (debug)
					cout << cmd << endl;
				cmdresult = system(cmd.c_str());
				if (cmdresult == 0)
					_unlink((exefile + ".manifest").c_str());
			}
		}

		if (read_from_stdin)
			unlink(sourcefile.c_str());

		return cmdresult;
	}
}
