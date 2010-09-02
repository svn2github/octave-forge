## Copyright (C) 2010 Philip Nienhuis, <prnienhuis@users.sf.net>
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} javamem
## @deftypefnx {Function File} [@var{jmem}] = javamem
## Show current memory status of the java virtual machine (JVM)
## & run garbage collector.
##
## When no return argument is given the info is echoed to the screen.
## Otherwise, cell array @var{jmem} contains Maximum, Total, and
## Free memory (in bytes).
##
## All java-based routines are run in the JVM's shared memory pool,
## a dedicated and separate part of memory claimed by the JVM from
## your computer's total memory (which comprises physical RAM and
## virtual memory / swap space on hard disk).
##
## The maximum available memory can be set using the file java.opts
## (in the same subdirectory where javaaddpath.m lives, see 
## "which javaaddpath". Usually that is: @*
## [/usr]/share/octave/packages/java-<version>.
##
## java.opts is a text file with just two lines. The first line specifies
## the initial memory size in megabytes, the second line specifies the
## requested maximum size (where 512 MB is the limit for java 1.6): @*
## -Xms64m @*
## -Xmx512m @*
## You can adapt these values if your system has limited available
## physical memory. When no java.opts file is present, the default
## assignments are 16 MB and 64MB, respectively.
##
## "Total memory" is what the operating system has currently assigned
## to the JVM and depends on actual and active memory usage.
## "Free memory" is self-explanatory. During operation of java-based
## octave functions the amounts of Total and Free memory will vary,
## due to java's own cleaning up and your operating system's memory
## management.
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2010-03-25
## Updates: 
## 2010-03-26 Changed name to javamem & indentation to double spaces

function [ j_mem ] = javamem ()

  rt = java_invoke ('java.lang.Runtime', 'getRuntime');
  rt.gc;
  jmem = cell (3, 1);
  jmem{1} = rt.maxMemory ().doubleValue ();
  jmem{2} = rt.totalMemory ().doubleValue ();
  jmem{3} = rt.freeMemory ().doubleValue ();

  if (nargout < 1)
    printf ("\nJava virtual machine (JVM) memory info:\n");
    printf ("Maximum available memory:        %5d MiB;\n", jmem{1} / 1024 / 1024);
    printf ("   (...running garbage collector...)\n");
    printf ("OK, current status:\n");
    printf ("Total memory in virtual machine: %5d MiB;\n", jmem{2} / 1024 / 1024);
    printf ("Free memory in virtual machine:  %5d MiB;\n", jmem{3} / 1024 / 1024);
    printf ("%d CPUs available.\n", rt.availableProcessors ());
  else
    j_mem = jmem;
  endif

endfunction
