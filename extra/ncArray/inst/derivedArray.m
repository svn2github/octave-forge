function da = derived(fun,param);

da = ncArray(DerivedArray(fun,param),dims(param{1}),coord(param{1}));
