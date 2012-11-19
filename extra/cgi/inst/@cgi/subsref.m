% Return parmaters with cgi.form.('param_name')

function val = subsref(self,idx)

assert(length(idx) == 2)
assert(strcmp(idx(1).type,'.'))
assert(strcmp(idx(1).subs,'form'))
assert(strcmp(idx(2).type,'.'))

val = getfirst(self,idx(2).subs);

