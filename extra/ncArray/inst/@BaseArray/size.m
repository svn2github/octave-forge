function sz = size(self,dim)

sz = self.sz;

if nargin == 2
    if dim > length(sz)
      sz = 1;
    else
      sz = sz(dim);
    end
end

