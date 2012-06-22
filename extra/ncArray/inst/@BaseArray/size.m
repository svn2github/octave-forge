function sz = size(self,dim)

sz = self.sz;

if nargin == 2
    sz = sz(dim);
end

