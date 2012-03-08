// Copyright (C) 2011 Piotr Krzyzanowski <piotr.krzyzanowski@mimuw.edu.pl>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation; either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, see <http://www.gnu.org/licenses/>.

#include <octave/oct.h>
#include "randmtzig.h"

/* 

IntSetBins2 class and its usage from 'Programming Pearls' 
by Jon Bentley, 2nd edition, available at 
http://netlib.bell-labs.com/cm/cs/pearls/sets.cpp.

The notice on http://netlib.bell-labs.com/cm/cs/pearls/code.html says
  "You may use this code for any purpose, 
  as long as you leave the copyright notice and book citation attached." 

*/ 

/* IntSetBins2 class Copyright (C) 1999 Lucent Technologies */
/* From 'Programming Pearls', 2nd edition, by Jon Bentley */
/* sets.cpp -- exercise set implementations on random numbers */

#include <set>

class IntSetBins2 {
private:
	unsigned int	n, bins;
	double maxval;
	struct node {
		double val;
		node *next;
	};
	node **bin, *sentinel, *freenode;
	node *rinsert(node *p, double t)
	{	if (p->val < t) {
			p->next = rinsert(p->next, t);
		} else if (p->val > t) {
			freenode->val = t;
			freenode->next = p;
			p = freenode++;
			n++;
		}
		return p;
	}
public:
	IntSetBins2(unsigned int maxelements, double pmaxval)
	{	bins = maxelements;
		maxval = pmaxval;
		freenode = new node[maxelements];
		bin = new node*[bins];
		sentinel = new node;
		sentinel->val = maxval;
		for (unsigned int i = 0; i < bins; i++)
			bin[i] = sentinel;
		n = 0;
	}
	unsigned int size() { return n; }
	void insert1(double t)
	{	unsigned int i = t / (1.0 + maxval/bins);
		bin[i] = rinsert(bin[i], t);
	}
	void insert(double t)
	{	node **p;
		unsigned int i = t / (1.0 + maxval/bins);
		for (p = &bin[i]; (*p)->val < t; p = &((*p)->next))
			;
		if ((*p)->val == t)
			return;
		freenode->val = t;
		freenode->next = *p;
		*p = freenode++;
		n++;
	}
	void report(double *v)
	{	unsigned int j = 0;
		for (unsigned int i = 0; i < bins; i++)
			for (node *p = bin[i]; p != sentinel; p = p->next)
				v[j++] = p->val;
	}
};


DEFUN_DLD (sample, args, , "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{s}} = sample (@var{m}, @var{n})\n\
Return @var{m} unique random integer values from 0..@var{n}-1,\n\
sorted in ascending order.\n\
\n\
Based on a code from Jon Bentley's \"Programming Pearls\", \n\
see @url{http://netlib.bell-labs.com/cm/cs/pearls/}.\n\
@end deftypefn")
{
	int nargin = args.length();
	if (nargin < 2)
	{
		print_usage ();
		return octave_value ();
	}
	
	unsigned int m;
	double M = args(0).scalar_value(); 	// temporarily allow for 
						// negative values of "m"
	double n = args(1).scalar_value(); 	// allow huge values of "n"
	if (M > n) 
		M = n;
	if (M <= 0)
		M = 0;
		
	m = M; // set actual "m" only after making sure it is not negative
	RowVector s(m);
  	
	/* as in the code from "Programming Pearls" */
	IntSetBins2 S(m, n);
	while (S.size() < m)
		S.insert(floor(oct_randu()*n)); // use Octave's uniform RNG
	S.report(s.fortran_vec());
	return octave_value (s);
}
/*
%!assert (isempty(sample(0,10)));
%!assert (isempty(sample(-2,10)));
%!assert (sample(10,10),[0:9]);
%!assert (sample(12,10),[0:9]);
%!assert (length(sample(9,10)),9);
%!shared a,m,n
%! m = 1e4-5;
%! n = 1e4;
%! a = sample(m,n);
%!assert (all(a<n));
%!assert (all(a>=0));
%!assert (length(a),m);
%! n = 1e300;
%! a = sample(m,n);
%!assert (all(a<n));
%!assert (all(a>=0));
%!assert (length(a),m);
%!demo
%! s = sample(4,8)
%! % s should contain an increasing sequence of 4 integers from the range 0..7
*/
