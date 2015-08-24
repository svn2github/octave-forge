function varargout = subsref(self,idx)

  p = {};
  for i = 1:length(self.params)
    %i,self.params{i},idx
    p{i} = subsref(self.params{i},idx);
  end

  varargout{1} = self.fun(p{:});