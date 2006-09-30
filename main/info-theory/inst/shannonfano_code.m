## (C) 2006, September 29, Muthiah Annamalai, <muthiah.annamalai@uta.edu>
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
##

## usage: shannonfano_code(symbol_probabilites)
##        computes the code words for the symbol probabilities using the
##        shannon fano scheme. Output is a cell array of strings, which 
##        are codewords, and correspond to the order of input probability.
##
##
## example: [CW]=shannonfano_code([0.5 0.25 0.15 0.1]);
##          assert(redundancy(CW,[0.5 0.25 0.15 0.1]),0.25841,0.001)
##
function [cw_list]=shannonfano_code(P)
  DMAX=length(P);
  S=1:DMAX;
#
#FIXME: Is there any other way of doing the
#topological sort? Insertion sort is bad.
#
#Sort the probability list in 
#descending/non-increasing order.
#Using plain vanilla insertion sort.
#
  for i=1:length(P)
    for j=i:length(P)
      
      if(P(i) < P(j))
	
				#Swap prob
	t=P(i);
	P(i)=P(j);
	P(j)=t;
	
				#Swap symb
	t=S(i);
	S(i)=S(j);
	S(j)=t;
      end
      
    end
  end
  
  
  #Now for each symbol you need to
  #create code as first [-log p(i)] bits of
  #cumulative function sum(p(1:i))
  #
  #printf("Shannon Codes\n");
  #data_table=zeros(1,DMAX);

   cw_list={};
   for i=1:length(S)
     if(P(i)>0)
       digits=ceil(-log2(P(i))); #somany digits needed
     else
       digits=0; #dont assign digits
     end
     
     Psum = sum([0 P](1:i)); #Cumulative probability
     s=binaryn(Psum,digits);
     if(length(s)==0)
       v=0;
     else
       v=bin2dec(s);
       if(v==0)
	 s=strcat("1",s);
	 v=bin2dec(s);
       end
     end
     # printf(" %d => %s %d %d\n",S(i),s,v,i);
     #data_table(S(i))=v;
     cw_list{i}=s;
   end
   
   #re-arrange the list accroding to input prob list.
   cw_list2={};
   for i=1:length(cw_list)
     cw_list2{i}=cw_list{S(i)};
   end
   cw_list=cw_list2;

   return;
end

%!
%!CW=shannonfano_code([0.5 0.25 0.15 0.1]);
%!assert(redundancy(CW,[0.5 0.25 0.15 0.1]),0.25841,0.001)
%!CW=shannonfano_code([0.5 0.15 0.25 0.1]);
%!
