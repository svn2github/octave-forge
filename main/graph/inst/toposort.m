function nodelist=toposort(C);
%function nodelist=toposort(C)
%This is a function which carries out a topological sort of a graph. See
%http://en.wikipedia.org/wiki/Topological_sorting.
%Given an input graph C, it outputs an ordered list of nodes
%nodelist which is topologically sorted.
%
% A demo is available by running toposort('demo').
% The input is a vector cell array C which holds the graph. For each
% node i, C{i} is a vector of nodes which node i depends on. A cell may
% be empty.
%
%the input is a linear cell array. each cell should be a vector
%containing the indices it depends on.
%
%The output is a column vector of indices in C, sorted in
%topological order.
%
%Author Paul Dreik 20101008
%License: GPL v2 or later, at your option.

if 0==nargin
    error('please supply one input argument');
end

if isequal(C,'demo')
    %this is the example on wikipedia as per 20100908
    C=cell(11,1);
    C{11}=[7 5];
    C{8}=[7 3];
    C{2}=11;
    C{9}=[8 11];
    C{10}=[3 11];
end

debug=false;

%go through the list and make sure it is sorted


%L - Empty list that will contain the sorted elements
L=[];
%S - Set of all nodes with no incoming edges
S=[];
for i=1:length(C)
   if isempty(C{i}) 
       S(end+1)=i;
   else
       %while we are at it, make sure the incoming graph is sorted
       %properly
       p=unique(C{i});
       C{i}=p;
       %check that the indices are in a valid range 1
       %to length(C). This check checks for nan as well.
       if ~all(p>=1 & p<=length(C))
           error('parent list for node %d contains nodes outside valid range.',i);
       end
   end
end
if debug
    disp(S)
end

%S is sorted from lowest node id to highest. This way nodes with
%low indices will be output prior to higher indices.

%while S is non-empty do
while ~isempty(S)
    %    remove a node n from S
    n=S(1);
    S=S(2:end);
    if debug
        printf('removing node %d from S. S is now\n',n);
        disp(S);
    end
    %    insert n into L
    L(end+1)=n;
    if debug
        printf('inserting node %d into L. L is now\n',n);
        disp(L);
    end
    %    for each node m with an edge e from n to m do
    %        remove edge e from the graph
    for i=1:length(C)
       m=i;
       children=C{m};
       if any(children==n)
           children(find(children==n))=[];
           C{m}=children;
           if debug
               printf('removing link %d to %d\n',n,m);
               disp(C);
           end

           %        if m has no other incoming edges then
           %            insert m into S
           if isempty(C{m})
               S(end+1)=m; 
               S=sort(S);
               if debug
                   printf('node %d now has no incoming edges. S is now\n',m);
                   disp(S);    
               end
           end
       end
    end
end

%if graph has edges then
%    output error message (graph has at least one cycle)
for i=1:length(C)
   if ~isempty(C{i})
      error('the graph has at least one cycle'); 
   end
end
%else 
%    output message (proposed topologically sorted order: L)

nodelist=L(:);
