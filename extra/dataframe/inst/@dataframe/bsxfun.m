function resu = bsxfun(func, A, B)

  resu = [];

  singletondim = find(B._cnt < 2);
  if !isempty(singletomdim), singletondim = singletondim(1); endif
    
  
  if !isempty(singletondim), %# was isvector(B)
    Bisscal = isscalar(B);
    if (!Bisscal),
      if (B._cnt(1) > 1),
	error('bsxfun on dataframes: only column iterations permitted');
      endif
      if (A._cnt(2) != max(B._cnt)),
	error('bsxfun: dimension mismatch');
      endif
    endif
    %# prepare to call to subsref / subsasgn
    SA.type = '()'; SA.subs={':', 1, ':'};
    SB.type = '()'; SB.subs = { 1 };
      
    if (Bisscal),
      for indi = 1:A._cnt(2),
	SA.subs{2} = indi;
	resu = subsasgn(resu, SA, @bsxfun(func, subsref(A, SA), B));
      endfor
    else
      for indi = 1:A._cnt(2),
	[SA.subs{2}, SB.subs{1}] = deal(indi);
	resu = subsasgn(resu, SA, @bsxfun(func, subsref(A, SA), subsref(B, SB)));
      endfor
    endif
  elseif isvector(A),
    resu = B;  Aisscal = isscalar(A);
    if (!Aisscal),
      if (A._cnt(1) > 1),
	error('bsxfun on dataframes: only column iterations permitted');
      endif
      if (B._cnt(2) != max(A.cnt)),
	error('bsxfun: dimension mismatch');
      endif
    endif
    
    %# prepare to call to subsref / subsasgn
    SA.type = '()'; SA.subs = { 1 };
    SB.type = '()'; SB.subs = {':', 1, ':'};
     
    if (Aisscal),
      for indi = 1:max(A._cnt),
	SB.subs{2} = indi;
	resu = subsasgn(resu, SB, @bsxfun(func, A, subsref(B, SB)));
      endfor
    else
      for indi = 1:max(B._cnt),
	[SA.subs{1}, SB.subs{2}] = deal(indi);
	resu = subsasgn(resu, SB, @bsxfun(func, subsref(A, SA), subsref(B, SB)));
      endfor
    endif
  else
    %# standard approach
    resu = df_func(func, A, B);
  endif
  
endfunction
