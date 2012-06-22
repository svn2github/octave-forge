% sz size of the array (with at least two elements)

function retval = BaseArray(sz)

self.sz = sz;

retval = class(self,'BaseArray');