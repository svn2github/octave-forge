## Copyright (C) 2007 Muthiah Annamalai <muthiah.annamalai@uta.edu>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} @var{rval}= {} combs(@var{sym_set},@var{k})
## Function generates the nchoosek(N,K) combinations, and returns it.
## compute the combinations nchoosek(length(@var{sym_set}), @var{k})
## nchoosek()  is a much faster variant of this function.
## @example
## @group
##
##           combs([1,2,3],2)
##           ##returns value [1 2; 1 3; 2 3]
##
##           combs(['a','e','i','o','u'],2)
##           ##returns value  [['a', 'e']; ['a', 'i']; ['a','o']; ['a','u']; ['e', 'i'];
##           ##['e','o']; ['e','u']; ['i','o']; ['i','u']; ['o', 'u'];]
##
## @end group
## @end example
## @end deftypefn
## @seealso {perms, nchoosek}

##
## Code modified from answer by 'leapinglizard-ga' on 
## Google Answers, posted on 01 Sep 2004 09:13 PDT,
## 

function L=combs(Set,K)
  if ( nargin < 2 )
    print_usage()
  end

  N=length(Set);
  %%printf("# of combinations = %g\n",nchoosek(N,K))
  L=comb_worker(K,1,Set,[],true);
  return
end

##
## sub-function
##
function L=comb_worker(K,P,Set,combo,is_first)
  persistent N
  persistent Result
  persistent count

  L={};

  if isempty(N)
    N=length(Set);
  end

  if isempty(Result)
    Result=[];
  end

  if (K == 0)
    count=count+1;
    Result=[Result; combo];
    %%combo;
    return
  else
    for idx=P:N
      C=Set(idx);
      combo=[combo C];
      comb_worker(K-1,idx+1,Set,combo,false);
      combo=combo(1:end-1);
    end

    if ( is_first > 0 )
      L=Result;

      %reset
      N=[];
      Result=[];
      count=[];

      return
    end

    return
  end
end

%!assert(combs([1,2,3],2),[1 2; 1 3; 2 3])
