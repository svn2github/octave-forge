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
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 * =========================================================================
 *
 * This code is a C translation of the fort77 package available from
 * ftp://sunsite.unc.edu/pub/Linux/devel/lang
 *
 */

#include <stdlib.h>
#include <pcre.h>
#include <list>
#include <string>
#include <stdarg.h>
#ifdef _MSC_VER
#include <io.h>
#define access _access
#define unlink _unlink
#endif

using namespace std;

static bool verbose = false;

void exit_with_error(const char *msg, ...)
{
	va_list ap;

	va_start(ap, msg);
	vfprintf(stderr, msg, ap);
	va_end(ap);
	fprintf(stderr, "\n");
	exit(-1);
}

void verbose_msg(const char *msg, ...)
{
	if (verbose)
	{
		va_list ap;
		va_start(ap, msg);
		vfprintf(stderr, msg, ap);
		va_end(ap);
	}
}

string parsewx(const string& wx)
{
	int pos = wx.find(',');
	if (pos != string::npos)
		return wx.substr(pos+1);
	return wx;
}

bool match(const char *pattern, const char *str, int len)
{
	const char *errmsg;
	int erroffset;
	pcre *re = pcre_compile(pattern, 0, &errmsg, &erroffset, NULL);
	int rc;

	if (re == NULL)
		exit_with_error("internal error: invalid regular expression - %s: %s", pattern, errmsg);
	rc = pcre_exec(re, NULL, str, strlen(str), 0, 0, NULL, 0);
	pcre_free(re);
	return (rc >= 0);
}

bool match(const char *pattern, const string& str)
{
	return match(pattern, &str[0], str.length());
}

void check_file_read(const string& filename)
{
	if (access(filename.c_str(), 4) != 0)
		exit_with_error("Cannot open ", filename.c_str());
}

string get_basename(const string& filename)
{
	int p1 = filename.rfind('.');
	int p2 = filename.rfind('/'), p3 = filename.rfind('\\');

	if (p3 < p2)
		p2 = p3;
	if (p2 == string::npos)
		return filename.substr(0, p1);
	else
		return filename.substr(p2, p1-p2-1);
}

string quote(const string& s)
{
	if (s.find(' ') != string::npos)
		return "\"" + s + "\"";
	else
		return s;
}

int do_system(const string& cmd)
{
	if (verbose)
		fprintf(stderr, "Running: %s\n", cmd.c_str());
	return system(cmd.c_str());
}

int do_system(const list<string>& args)
{
	string cmd;

	for (list<string>::const_iterator it = args.begin(); it != args.end(); ++it)
	{
		if (!cmd.empty())
			cmd += " ";
		cmd += quote(*it);
	}
	return do_system(cmd);
}

string join(const string& sep, const list<string>& l)
{
	string result;

	for (list<string>::const_iterator it = l.begin(); it != l.end(); ++it)
	{
		if (!result.empty())
			result += sep;
		result += *it;
	}
	return result;
}

void list_append(list<string>& dest, const list<string>& src)
{
	for (list<string>::const_iterator it = src.begin(); it != src.end(); ++it)
		dest.push_back(*it);
}

string get_env_var(char *name, char *defval)
{
	char *result = getenv(name);
	if (!result || strlen(result) == 0)
		result = defval;
	return string(result);
}

int main (int argc, char **_argv)
{
	list<string> copts, fopts, lopts, cppopts, pfiles, argv, includes;
	string nnflag = "-Nn802", output, cc = get_env_var("CC", "cc-msvc");
	bool extract_prototypes = false, cpp = false, debug = false, optimize = false, compile_only = false;
	bool keep_c = false;
	int retcode;

	if (cc == "fc-msvc")
	{
		// Recursive call: this case can happen when called from configure script
		cc = "cc-msvc";
	}

	for (int i=1; i<argc; i++)
	{
		char *carg = _argv[i];
		int len = strlen(carg);
		string arg(carg);

#define MATCH(p) match(p, carg, len)

		if (!MATCH("^-"))
		{
			if (MATCH("\\.P$"))
				pfiles.push_back(arg);
			else
				argv.push_back(arg);
			continue;
		}

		// f2c options

		if (MATCH("^-[CUuaEhRrz]$") || MATCH("^-I[24]$") || MATCH("^-onetrip$") || MATCH("^-![clPR]$") ||
		    MATCH("^-ext$") || MATCH("^-!bs$") || MATCH("^-W[1-9][0-9]*$") || MATCH("^-w8$") || MATCH("^-w66$") ||
		    MATCH("^-r8$") || MATCH("^-N[^n][0-9]+$"))
		{
			fopts.push_back(arg);
		}
		else if (MATCH("^-Nn[0-9]+$"))
		{
			nnflag = arg;
		}
		else if (MATCH("^-Ps?"))
		{
			extract_prototypes = true;
			fopts.push_back(arg);
		}
		else if (MATCH("^-cpp$"))
		{
			cpp = true;
		}
		else if (MATCH("^-w$"))
		{
			fopts.push_back(arg);
			copts.push_back(arg);
		}
		else if (MATCH("^-g$"))
		{
			fopts.push_back(arg);
			copts.push_back(arg);
			lopts.push_back(arg);
			debug = true;
		}
		else if (MATCH("^-Wf,"))
		{
			fopts.push_back(parsewx(arg));
		}
		else if (MATCH("^-Wp,"))
		{
			cppopts.push_back(parsewx(arg));
		}
		else if (MATCH("^-W[ca],"))
		{
			copts.push_back(parsewx(arg));
		}
		else if (MATCH("^-Wl,"))
		{
			lopts.push_back(parsewx(arg));
		}
		else if (MATCH("^-f$"))
		{
			fopts.push_back(arg);
		}
		else if (MATCH("^-[fWUAm]") || MATCH("^-[Ex]$") || MATCH("^-pipe$"))
		{
			copts.push_back(arg);
		}
		else if (MATCH("^-I$"))
		{
			if (i >= (argc-1))
				exit_with_error("%s: missing argument to -I", _argv[0]);
			includes.push_back("-I" + string(_argv[++i]));
		}
		else if (MATCH("^-I."))
		{
			includes.push_back(arg);
		}
		else if (MATCH("^-o$"))
		{
			if (i >= (argc-1))
				exit_with_error("%s: missing argument to -o", _argv[0]);
			output = _argv[++i];
		}
		else if (MATCH("-o."))
		{
			output = arg.substr(2);;
		}
		else if (MATCH("^-O"))
		{
			copts.push_back(arg);
			lopts.push_back(arg);
			optimize = true;
		}
		else if (MATCH("^-[Og]") || MATCH("^-p$") || MATCH("^-pg$"))
		{
			copts.push_back(arg);
			lopts.push_back(arg);
		}
		else if (MATCH("^-[bV]$"))
		{
			if (i >= (argc-1))
				exit_with_error("%s: missing argument to %s", _argv[0], carg);
			string narg = _argv[++i];
			copts.push_back(arg);
			copts.push_back(narg);
			lopts.push_back(arg);
			lopts.push_back(narg);
		}
		else if (MATCH("^-[bV]."))
		{
			copts.push_back(arg);
			lopts.push_back(arg);
		}
		else if (MATCH("-[lL]$"))
		{
			if (i >= (argc-1))
				exit_with_error("%s: missing argument to %s", _argv[0], carg);
			lopts.push_back(arg);
			lopts.push_back(string(_argv[++i]));
		}
		else if (MATCH("^-[lL].") || MATCH("^-nostartfiles$") || MATCH("^-static$") || MATCH("^-shared$") || MATCH("^-symbolic$"))
		{
			lopts.push_back(arg);
		}
		else if (MATCH("^-[cS]$"))
		{
			compile_only = true;
		}
		else if (MATCH("^-D"))
		{
			cppopts.push_back(arg);
		}
		else if (MATCH("^-v$"))
		{
			verbose = true;
		}
		else if (MATCH("^-k$"))
		{
			keep_c = true;
		}
		else
		{
			copts.push_back(arg);
		}
	}

	fopts.push_back(nnflag);
	for (list<string>::const_iterator it = includes.begin(); it != includes.end(); ++it)
	{
		cppopts.push_back(*it);
		fopts.push_back(*it);
	}
	fopts.push_back("-I.");
	for (list<string>::const_iterator it = pfiles.begin(); it != pfiles.end(); ++it)
		fopts.push_back(*it);
#ifdef _MSC_VER
	copts.push_back("-MD");
	lopts.push_back("-subsystem:console");
#endif

	if (compile_only && !output.empty() && argv.size() > 1)
	{
		fprintf(stderr, "%s: warning: -c and -o with multiple files, ignoring -o\n", _argv[0]);
		output = "";
	}

	if (argv.size() == 0)
		exit_with_error("%s: no input file specified", _argv[0]);

	list<string> lfiles, gener_lfiles;
	int seq = 0;

	for (list<string>::const_iterator it = argv.begin(); it != argv.end(); ++it)
	{
		string ffile, cfile, lfile, basefile, debugcmd;
		string arg = *it;
#undef MATCH
#define MATCH(p) match(p, arg)

		if (MATCH("\\.[fF]$"))
		{
			ffile = arg;
			basefile = ffile;
		}
		else if (MATCH("\\.[cCisSm]$") || MATCH("\\.cc$") || MATCH("\\.cxx$"))
		{
			cfile = arg;
			basefile = cfile;
		}
		else
		{
			lfiles.push_back(arg);
		}

		seq++;

		if (!ffile.empty())
		{
			check_file_read(ffile);
			if (keep_c)
				cfile = get_basename(ffile) + ".c";
			else
				cfile = "fc-msvc-" + get_basename(ffile) + "-tmp.c";

			if (cpp || match("\\.F$", ffile))
			{
				// TODO?
			}
			else
			{
				printf("%s\n", ffile.c_str());
				retcode = do_system("f2c " + join(" ", fopts) + " < " + ffile + " > " + cfile);
			}

			if (retcode != 0 && !keep_c)
			{
				verbose_msg("%s: unlinking %s\n", _argv[0], cfile.c_str());
				unlink(cfile.c_str());
				exit_with_error("%s: aborting compilation", _argv[0]);
			}

			if (extract_prototypes)
			{
				// TODO?
			}
		}

		if (!cfile.empty())
		{
			list<string> command;

			command.push_back(cc);
			list_append(command, cppopts);
			list_append(command, copts);
			if (compile_only && !output.empty())
			{
				command.push_back("-o");
				command.push_back(output);
				command.push_back("-c");
			}
			else
			{
				lfile = get_basename(basefile) + ".o";
				command.push_back("-o");
				command.push_back(lfile);
				command.push_back("-c");
			}
			command.push_back(cfile);
			retcode = do_system(command);

			if (retcode != 0)
			{
				verbose_msg("%s: unlinking %s\n", _argv[0], cfile.c_str());
				unlink(cfile.c_str());
				exit_with_error("%s: aborting compilation", _argv[0]);
			}
			if (!ffile.empty() && !keep_c)
			{
				verbose_msg("%s: unlinking %s\n", _argv[0], cfile.c_str());
				unlink(cfile.c_str());
			}
			if (!lfile.empty())
			{
				gener_lfiles.push_back(lfile);
				lfiles.push_back(lfile);
				lfile = "";
			}
		}

		if (!lfile.empty())
			lfiles.push_back(lfile);
	}

	if (!compile_only)
	{
		list<string> command;

		command.push_back(cc);
		if (!output.empty())
		{
			command.push_back("-o");
			command.push_back(output);
		}
		list_append(command, lfiles);
		list_append(command, lopts);
		command.push_back("-lf2c");
#ifndef _MSC_VER
		command_push_back("-lm");
#endif
		retcode = do_system(command);

		if (gener_lfiles.size() > 0)
		{
			verbose_msg("%s: unlinking %s\n", _argv[0], join(",", gener_lfiles).c_str());
			for (list<string>::const_iterator it = gener_lfiles.begin(); it != gener_lfiles.end(); ++it)
				unlink((*it).c_str());
		}

		return retcode;
	}

	return 0;
}
