/*
 *
 * Copyright (c) 1997-1998 Henrik Seidel
 * Copyright (c) 1999-2003 Grace Development Team
 *
 * Copyright (C) 2002 Chee Kiang Goh
 *    * initial octave interface
 *
 * Copyright (C) 2003 Teemu Ikonen
 *    * improvements on the octave interface
 * 
 *
 *                           All Rights Reserved
 *
 *    This library is free software; you can redistribute it and/or
 *    modify it under the terms of the GNU Library General Public
 *    License as published by the Free Software Foundation; either
 *    version 2 of the License, or (at your option) any later version.
 *
 *    This library is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *    Library General Public License for more details.
 *
 *    You should have received a copy of the GNU Library General Public
 *    License along with this library; if not, write to the Free
 *    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <octave/oct.h>
#include <unistd.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <strings.h>
#include <errno.h>
#include <limits.h>
#include <string>
#include <map>
#ifndef OPEN_MAX
#  define OPEN_MAX 256
#endif

#define SIZEOF_CHAR sizeof(char)

class Graphdata {
public:
    short cur_set;
    short max_set;

    Graphdata():cur_set(-1), max_set(-1) {
    }};


class Gracedata {
public:
    char *buf;			/* write buffer */
    int bufsize;		/* size of the write buffer */
    int bufsizeforce;   /* threshold for forcing a flush */
    int fd_pipe;
    bool broken_pipe;	/* is the pipe broken ? */
    pid_t pid;
    short cur_graph;
    std::map < int, Graphdata > graphs;

    Gracedata():buf(NULL), fd_pipe(-1), broken_pipe(false),
                pid((pid_t) - 1), cur_graph(0) { }
};


/* static global variables */
static std::map < int, Gracedata > graces;
static bool ate_already = false;
static short cur_figure = 0;
static bool holdon = false;


void gr_close(void)
{
}

// Doesn't really work well, for example, calling system() kills all
// Grace windows.
// void gr_close(void)
// {
//     typedef std::map<int, Gracedata>::iterator I;

//     signal(SIGPIPE,SIG_IGN);// To make sure that we do not trigger ourselve again after closing pipe
//     signal(SIGCHLD,SIG_IGN);// To make sure that we do not trigger ourselve again after killing the child

//     for(I p = graces.begin(); p != graces.end(); ++p) {
//         Gracedata& g = (p->second);
//         g.broken_pipe = 1;
//         if (g.fd_pipe != -1) {
//             close(g.fd_pipe);
//             g.fd_pipe = -1;
//         }
//         if (g.pid != (pid_t) -1) {
//             kill(g.pid, SIGTERM);
//                 /* Wait until grace exit */
//             waitpid (g.pid, NULL, 0);
//         }
//         free (g.buf);
//     }
// }

void gr_close2(int sigvoid)
{
    gr_close();
}

void gr_killgrace(int fig)
{
    Gracedata & g = graces[fig];

    g.broken_pipe = 1;
    if (g.fd_pipe != -1) {
        close(g.fd_pipe);
        g.fd_pipe = -1;
    }
    if (g.pid != (pid_t) - 1) {
        kill(g.pid, SIGTERM);
        /* Wait until grace exit */
        waitpid(g.pid, NULL, 0);
    }
    free(g.buf);
    if (!graces.erase(fig)) {
        printf("grplot: something seriously wrong with graces map\n");
    }
}



/*
 * try to send data to grace (on pass only)
 */
static int gr_write(int left)
{
    int written;

    Gracedata & g = graces[cur_figure];
    written = write(g.fd_pipe, g.buf, left);

    if (written > 0) {

        left -= written;

        if (left > 0) {
            /* move the remaining characters (and the final '\0') */
            bcopy(g.buf + written, g.buf, left + 1);
        } else {
            /* clear the buffer */
            *(g.buf) = '\0';
        }

    } else if (written < 0) {
        printf("grplot: problem writing to pipe !\n");
        if (errno == EPIPE)
            /* Grace has closed the pipe : we cannot write anymore */
            gr_killgrace(cur_figure);
        return (-1);
    }

    return (left);
}

int gr_open_pipe(int fig, char *exe, int bs, ...)
{
    int i, fd[2];
    int retval;
    char fd_number[4];
    va_list ap;
    char **arglist;
    char *s;
    int numarg;

    Gracedata & g = graces[fig];

    if (g.fd_pipe != -1) {
        printf("grplot:Grace subprocess already running\n");
        return (-1);
    }

    /* Set the buffer sizes according to arg */
    if (bs < 64) {
        printf("grplot:The buffer size in GraceOpenVA should be >= 64\n");
        return (-1);
    }
    g.bufsize = bs;
    g.bufsizeforce = bs / 2;
    if (!ate_already) {
        atexit(gr_close);
        ate_already = true;
    }

    /* Make the pipe */
    if (pipe(fd)) {
        printf("grplot:problem creating the pipe !\n");
        return (-1);
    } else
        signal(SIGPIPE, gr_close2);	//add watch on pipe only if pipe is successfully opened.

    /* Fork a subprocess for starting grace */
    g.pid = vfork();
    if (g.pid == (pid_t) (-1)) {
        printf("grplot: problem forking child process !\n");
        return (-1);
    }
    /* If we are the child, replace ourselves with grace */
    if (g.pid == (pid_t) 0) {
        for (i = 0; i < OPEN_MAX; i++) {
            /* we close everything except stdin, stdout, stderr
               and the read part of the pipe */
            if (i != fd[0] &&
                i != STDIN_FILENO &&
                i != STDOUT_FILENO && i != STDERR_FILENO) {
                close(i);
            }
        }
        
        /* build the argument list */
        va_start(ap, bs);
        numarg = 3;
        arglist = (char **) malloc((numarg + 1) * sizeof(char *));
        arglist[0] = exe;
        arglist[1] = "-dpipe";
        sprintf(fd_number, "%d", fd[0]);
        arglist[2] = fd_number;
        while ((s = va_arg(ap, char *)) != NULL) {
            numarg++;
            arglist =
                (char **) realloc(arglist, (numarg + 1) * sizeof(char *));
            arglist[numarg - 1] =
                (char *) malloc((strlen(s) + 1) * SIZEOF_CHAR);
            strcpy(arglist[numarg - 1], s);
        }
        arglist[numarg] = NULL;
        va_end(ap);
        
        retval = execvp(exe, arglist);
        
        if (retval == -1) {
            printf("grplot: Cannot start %s\n", exe);
            exit(1);
        } else {
            exit(0);
        }
    }

    /* We are the parent -> keep the write part of the pipe
       and allocate the write buffer */
    if (g.pid != ((pid_t) 0) && g.pid != ((pid_t) (-1)))
        signal(SIGCHLD, gr_close2);

    g.buf = (char *) malloc(g.bufsize);
    if (g.buf == NULL) {
        printf("grplot: Not enough memory");
        close(fd[0]);
        close(fd[1]);
        return (-1);
    }
    *(g.buf) = '\0';

    close(fd[0]);
    g.fd_pipe = fd[1];
    g.broken_pipe = false;

    return (0);
}

bool gr_is_open(int fig)
{
    Gracedata & g = graces[fig];
    char *teststr = " ";
    int written;

    if (g.fd_pipe < 0)
        return false;

    // write a space to test if a grace process is listening,
    // this should not affect the parsing of subsequent commands
    written = write(g.fd_pipe, teststr, 1);
    if (written == 1)
        return true;
    else {
        // Grace has closed the pipe : we cannot write anymore 
        printf("grplot: problem writing to pipe !\n");
        gr_killgrace(cur_figure);
        return false;
    }
//    return (graces[fig].fd_pipe >= 0) ? 1 : 0;
}

int gr_flush(void)
{
    int loop, left;

    Gracedata & g = graces[cur_figure];

    if (g.fd_pipe == -1) {
        printf("grplot:No grace subprocess\n");
        return (-1);
    }

    left = strlen(g.buf);

    for (loop = 0; loop < 30; loop++) {
        left = gr_write(left);
        if (left < 0) {
            return (-1);
        } else if (left == 0) {
            return (0);
        }
    }

    printf("grplot: flush ran into eternal loop");
    return (-1);

}

int gr_cmd(const char *cmd)
{
    int left;

    Gracedata & g = graces[cur_figure];

    if (g.fd_pipe == -1) {
        printf("grplot:No grace subprocess\n");
        return (-1);
    }

    /* Append the new string to the global write buffer */
    if (strlen(g.buf) + strlen(cmd) + 2 > (unsigned) g.bufsize) {
        printf("grplot: Buffer full");
        return (-1);
    }
    strcat(g.buf, cmd);
    strcat(g.buf, "\n");
    left = strlen(g.buf);

    /* Try to send the global write buffer to grace */
    left = gr_write(left);
    if (left >= g.bufsizeforce) {
        if (gr_flush() != 0) {
            return (-1);
        }
    } else if (left < 0) {
        return (-1);
    }

    return (0);
}

int gr_printf(const char *fmt, ...)
{
    va_list ap;
    char *str;
    int nchar;

    Gracedata & g = graces[cur_figure];

    if (g.fd_pipe == -1) {
        printf("grplot:No grace subprocess\n");
        return (0);
    }

    /* Allocate a new string buffer for the function arguments */
    str = (char *) malloc((size_t) g.bufsize);
    if (str == (char *) NULL) {
        printf("grplot: Not enough memory");
        return (0);
    }
    /* Print to the string buffer according to the function arguments */
    va_start(ap, fmt);
    nchar = vsprintf(str, fmt, ap);
    va_end(ap);
    nchar++;			/* This is for the appended "\n" */
    if (gr_cmd(str) == -1) {
        nchar = 0;
    }
    free(str);
    return (nchar);
}

int gr_sendcmd(std::string cmd)
{
    sigset_t set, oset;
    int ret;
    char buffer[256];

    sigemptyset(&set);
    sigaddset(&set, SIGINT);
    sigprocmask(SIG_BLOCK, &set, &oset);

    if (!gr_is_open(cur_figure)) {
        ret = gr_open_pipe(cur_figure,
                           "xmgrace", 8192, "-nosafe", "-free", NULL);
    }

    strncpy(buffer, cmd.c_str(), cmd.length());
    *(buffer + cmd.length()) = '\0';

    gr_cmd(buffer);

    sigprocmask(SIG_SETMASK, &oset, NULL);

    return ret;
}


// Octave-visible API

DEFUN_DLD(__grinit__, args,, "Initialize Grace plotting interface\n\
\n\
Renames the built-in functions hold and ishold to ghold and gishold,\n\
so that override with m-files is possible.\n\
")
{
    symbol_record *sym_rec;
    
    sym_rec = fbi_sym_tab->lookup ("hold", true);
    if( sym_rec->is_builtin_function() ) {
        sym_rec->unprotect ();
        fbi_sym_tab->rename("hold", "ghold");
        fbi_sym_tab->clear("hold");
        curr_sym_tab->clear("hold");
        sym_rec->protect ();
    }

    sym_rec = fbi_sym_tab->lookup ("ishold", true);
    if( sym_rec->is_builtin_function() ) {
        sym_rec->unprotect ();
        fbi_sym_tab->rename("ishold", "gishold");
        fbi_sym_tab->clear("ishold");
        curr_sym_tab->clear("ishold");
        sym_rec->protect ();
    }
    
    return octave_value_list();
}

DEFUN_DLD(__grexit__, args,, "Shut down the Grace plotting interface\n\
\n\
Undoes the effect of __grinit__.")
{
    symbol_record *sym_rec;

    sym_rec = fbi_sym_tab->lookup ("ghold", true);
    if( sym_rec->is_builtin_function() ) {
        fbi_sym_tab->clear("hold");
        curr_sym_tab->clear("hold");
        sym_rec->unprotect ();
        fbi_sym_tab->rename("ghold", "hold");
        sym_rec->protect ();
        fbi_sym_tab->clear("ghold");
        curr_sym_tab->clear("ghold");
    }

    sym_rec = fbi_sym_tab->lookup ("gishold", true);
    if( sym_rec->is_builtin_function() ) {
        fbi_sym_tab->clear("ishold");
        curr_sym_tab->clear("ishold");
        sym_rec->unprotect ();
        fbi_sym_tab->rename("gishold", "ishold");
        sym_rec->protect ();
        fbi_sym_tab->clear("gishold");
        curr_sym_tab->clear("gishold");
    }
    
    return octave_value_list();
}

DEFUN_DLD(__grclf__, args,, "Clear the current figure from all graphs.\n")
{
    typedef std::map < int, Graphdata >::const_iterator CI;
    
    Gracedata & g = graces[cur_figure];
    
    for (CI p = g.graphs.begin(); p != g.graphs.end(); p++) {
        gr_printf("kill g%i", p->first);
    }
    g.graphs.erase(g.graphs.begin(), g.graphs.end());
    g.graphs[0] = Graphdata();
    
    g.cur_graph = 0;
    
    gr_sendcmd("redraw");
    
    return octave_value_list();    
}

DEFUN_DLD(__grcla__, args,, "Clear the current graph from all sets.\n")
{
    Gracedata & g = graces[cur_figure];
    Graphdata & gd = g.graphs[g.cur_graph];
    
    for (int i = 0; i <= gd.max_set; i++) {
        gr_printf("kill g%i.s%i", g.cur_graph, i);
    }
    
    gd.cur_set = -1;
    gd.max_set = -1;
    
    gr_sendcmd("redraw");
    
    return octave_value_list();
}

DEFUN_DLD(__grhold__, args,, \
          " Tell Octave to hold the current data on the plot when executing\n\
 subsequent plotting commands.  This allows you to execute a series\n\
 of plot commands and have all the lines end up on the same figure.\n\
 The default is for each new plot command to clear the plot device\n\
 first.  For example, the command\n\n\
  grhold on\n\n\
 turns the hold state on.  An argument of off' turns the hold state\n\
 off, and hold' with no arguments toggles the current hold state.\n")
{

    if (args.length() == 0) {
        if(holdon)
            holdon = false;
        else
            holdon = true;
    } else {
        if ((args.length() > 1) || (!args(0).is_string())) {
            print_usage("grhold");
        }
        std::string s = args(0).string_value();
        if (s == "on")
            holdon = true;
        else if (s == "off")
            holdon = false;
        else
            print_usage("grhold");
    }
    
    return octave_value_list();
}

DEFUN_DLD(__grishold__,,,
          "Return 1 if the next line will be added to the current plot, or 0\n\
if the plot device will be cleared before drawing the next line.\n")
{
    ColumnVector out(1);
    if (holdon)
        out.elem(0) = 1.0;
    else
        out.elem(0) = 0.0;
    return octave_value(out);
}

DEFUN_DLD(__grfigure__, args,, "grfigure(N)\n\
Set the current plot window to plot window N.\n")
{
    ColumnVector out(1);

    if ((args.length() == 1) && (args(0).is_real_type())) {
        cur_figure = (args(0).int_value());
        gr_sendcmd("redraw;");
    }
    out.elem(0) = static_cast < double >(cur_figure);
    return octave_value(out);
}

DEFUN_DLD(__grsetgraph__, args,, "__grsetgraph__(n)\n\
Set the current graph number to n on the current figure.\n\
For m-file implementations.\n")
{
    ColumnVector out(1);
    int n;
    Gracedata & g = graces[cur_figure];

    if ((args.length() == 1) && (args(0).is_real_type())) {
        g.cur_graph = (args(0).int_value());
    }
    
    out.elem(0) = static_cast < double >(g.cur_graph);
    return octave_value(out);
}

DEFUN_DLD(__grnewset__, args,, "__grnewset__()\n\
Create a new set in the current graph.\n\
Must be called before a new set is plotted. For m-file implementations.\n")
{
    //   typedef std::map<int, bool>::const_iterator CI;

    ColumnVector out(1);
    int lastindex, newset;
    Gracedata & g = graces[cur_figure];
    Graphdata & gd = g.graphs[g.cur_graph];

//      CI p = gd.sets.rbegin();
//      lastindex = p->first;
//      newset = lastindex + 1;
//      gd.sets[newset] = true;
//      gd.cur_set = newset;
    gd.max_set++;
    gd.cur_set = gd.max_set;

    out.elem(0) = static_cast < double >(gd.cur_set);
    return octave_value(out);
}

DEFUN_DLD(__grcmd__, args,, "__grcmd__(string)\n\n\
Send a native command to grace.\n")
{
    std::string cmd_string;
    ColumnVector out(1);

    if ((args.length() > 0) && args(0).is_string()) {
        cmd_string = args(0).string_value();
        out(0) = (double) gr_sendcmd(cmd_string);
    } else {
        print_usage("__grcmd__");
        out(0) = -1.0;
    }

    return octave_value(out);
}


DEFUN_DLD(__grgetstat__, args,,
          "[cur_figure, cur_graph, cur_set] = __grgetstat__();\n\n\
Get the current figure, graph and set from grace.\n") {
    std::string cmd_string;
    ColumnVector cfig(1);
    ColumnVector cgrf(1);
    ColumnVector cset(1);
    octave_value_list ret;

    Gracedata & g = graces[cur_figure];
    Graphdata & gd = g.graphs[g.cur_graph];

    cfig(0) = static_cast < double >(cur_figure);
    cgrf(0) = static_cast < double >(g.cur_graph);
    cset(0) = static_cast < double >(gd.cur_set);

    ret(0) = octave_value(cfig);
    ret(1) = octave_value(cgrf);
    ret(2) = octave_value(cset);

    return ret;
}

