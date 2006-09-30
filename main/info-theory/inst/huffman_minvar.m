## (C) 2006, May 31, Muthiah Annamalai, <muthiah.annamalai@uta.edu>
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
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## usage: huffman_minvar(source probability vector, {toggle})
## toggle is a 1,0 optional argument that starts building a
## code based on 1's or 0's, defaulting to 0. Computes the 
## minimum variance huffman code, which can potentially cut down
## on the buffering need, using an even weight distribution.
##
##
## This function builds a Huffman code,
## given the probability list.
## The Huffman codes persymbol are output
## as a list of strings-per-source symbol.
## This function is the minimum variance method of building
## Huffman codes, such that the newly combined strings are
## promoted to the top of the tree.
##
## example: huffman([0.5 0.25 0.15 0.1]) => CW(0,10,111,110)
##          huffman(0.25*ones(1,4)) => CW(11,10,01,00)
##
## see also: huffman
##
function cw_list=huffman_minvar(source_prob,togglecode)
  if nargin < 1
    error("Usage: huffman(source_prob,{togglecode 1-0 in code});")
  elseif nargin < 2
    togglecode=0;
  end


##
## Huffman code algorithm.
## while (uncombined_symbols_remain)
##       combine least probable symbols into one with,
##       their probability being the sum of the two.
##       save this result as a stage at lowest order rung.
##       (Moving to lowest position possible makes it non-minimum variance
##        entropy coding)
## end
##
## for each (stage)
## Walk the tree we built, and assign each row either 1,
## or 0 of 
## end
## 
## reverse each symbol, and dump it out.
## 
## 

  %
  %need to find & eliminate the zero-probability code words.
  %in practice we donot need to assign anything to them.
  %
  origsource_prob=source_prob;

  %
  %sort the list and know the index transpositions.
  %
  L=length(source_prob);
  index=[1:L];
  for itr1=1:L
    for itr2=itr1:L
      if(source_prob(itr1) < source_prob(itr2))
	t=source_prob(itr1);
	source_prob(itr1)=source_prob(itr2);
	source_prob(itr2)=t;

	t=index(itr1);
	index(itr1)=index(itr2);
	index(itr2)=t;
      end
    end
  end
  %index
  %source_prob;
  
  idx=find(source_prob==0);
  if(not(isempty(idx)))    
    source_prob=source_prob(1:idx(1)-1);
  end
  clear idx;

  stage_list={};
  cw_list={};

  stage_curr={};
  stage_curr.prob_list=source_prob;
  stage_curr.sym_list={};
  S=length(source_prob);
  for i=1:S; 
    stage_curr.sym_list{i}=[i];
    cw_list{i}="";
  end


  I=1;
  while (I<S)
    L=length(stage_curr.prob_list);
    nprob=stage_curr.prob_list(L-1)+stage_curr.prob_list(L);
    nsym=[stage_curr.sym_list{L-1}(1:end),stage_curr.sym_list{L}(1:end)];

    %stage_curr;
    %archive old stage list.
    stage_list{I}=stage_curr;

    %
    %insert the new probability into the list, at the
    %first-position (greedy?) possible.
    %
    for i=1:(L-2)
      if(stage_curr.prob_list(i)<=nprob)
	break;
      end
    end
    
    stage_curr.prob_list=[stage_curr.prob_list(1:i-1) nprob stage_curr.prob_list(i:L-2)];
    stage_curr.sym_list={stage_curr.sym_list{1:i-1}, nsym, stage_curr.sym_list{i:L-2}};

    % Loopie
    I=I+1;
  end

  one_cw="1";
  zero_cw="0";


  if (togglecode==0)
      one_cw="1";
      zero_cw="0";
  else
     one_cw="0";
     zero_cw="1";
  end

  %printf("Exit Loop");
  I=I-1;
  while (I>0)
    stage_curr=stage_list{I};
    L=length(stage_curr.sym_list);

    clist=stage_curr.sym_list{L};
    for k=1:length(clist)
      cw_list{clist(k)}=strcat(cw_list{clist(k)},one_cw);
    end

    clist=stage_curr.sym_list{L-1};
    for k=1:length(clist)
      cw_list{clist(k)}=strcat(cw_list{clist(k)},zero_cw);
    end

    % Loopie
    I=I-1;
  end

  %
  %zero all the code-words of zero-probability length, 'cos they
  %never occur.
  %
  S=length(source_prob);
  for itr=(S+1):length(origsource_prob)
    cw_list{itr}="";
  end
  cw_list;

  %
  % Re-sort the indices according to the probability list.
  %
  L=length(source_prob);
  for itr=1:(L)
    if(index(itr)==-1)
      continue;
    end
    
    t=cw_list{index(itr)};
    cw_list{index(itr)}=cw_list{itr};
    cw_list{itr}=t;
    
    index(index(itr))=-1;
    
  end

  
  %zero all the code-words of zero-probability length, 'cos they
  %never occur.
  
  %for itr=1:L
  %  if(origsource_prob(itr)==0)
  %    cw_list{itr}="";
  %  end
  %end

  return
end
%!assert(huffman_minvar(0.25*ones(1,4),1),{"11","10","01","00"},0)
