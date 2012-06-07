% x = ncread(filename,varname)
% x = ncread(filename,varname,start,count,stride)
% read the variable varname from file filename.

function x = ncread(filename,varname,start,count,stride)

nc = netcdf(filename,'r');
nv = nc{varname};
sz = size(nv); sz = sz(end:-1:1);
nd = ndims(nv);

if nargin == 2
  start = ones(1,nd);
  count = inf*ones(1,nd);
end

if nargin < 5
  stride = ones(1,nd);
end

% end index

endi = start + (count-1).*stride;

% replace inf in count

i = endi == inf;
endi(i) = sz(i);


% load data

% subsref structure
subsr.type = '()';
subsr.subs = cell(1,nd);
for i=1:nd
  subsr.subs{nd-i+1} = start(i):stride(i):endi(i);
end
start,endi

x = subsref(nv,subsr);

% apply attributes

factor = nv.scale_factor(:);
offset = nv.add_offset(:);
fv = nv.FillValue_;

if ~isempty(fv)
  x(x == fv) = NaN;
else
  fv = nv.missing_value;
  
  if ~isempty(fv)
    x(x == fv) = NaN;
  end  
end

if ~isempty(factor)
  x = x * factor;
end

if ~isempty(offset)
  x = x + offset;
end

x = permute(x,[ndims(x):-1:1]);

