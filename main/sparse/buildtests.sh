#!/bin/sh

# ./buildtest.sh preset
#    creates sptest.m with preset tests.
#    Use sptest() from octave to run the tests.
#    The test log is in sptest.log
#
# ./buildtest.sh random
#    Creates sprandomtest.m with randomly generated matrices.
#    The test log is appended to sprandomtest.log
#    See help sprandomtest for an example

# buildtest.sh generates tests for real and complex sparse matrices.
# Also, we want to run both fixed tests with known outputs (quick tests)
# and longer tests with unknown outputs (thorough tests).  This requires
# two sets of tests --- one which uses preset matrices and another which
# uses randomly generated matrices.
#
# The tests are mostly identical for each case but the code is different,
# so it is important that the tests be run on all cases.  Because our test 
# harness doesn't have support for looping or macros (it is only needed
# for new data types), but sh does, we use sh to generate inline versions of
# the tests for each case.
#
# Our 'macros' use shared variables as parameters.  This allows us to
# for example define A complex and include all the unary ops tests, 
# then set A=spreal(A) and include all the unary ops tests.  Thus the
# same tests work for real and complex.  For binary tests it is even
# more complicated because we want full X sparse, sparse X full and
# sparse X sparse tested.
#
# We use the following macros:
#
#    gen_section
#        place a separator in the test file
#    gen_function
#        define the function definion
#    helper gen_specific
#        specific tests such as error handling and null input
#    helper gen_eat_zeros
#        make sure sparse-scalar ops which generate 0 work
#    gen_specific_tests
#        specific and eat zeros tests 
#    helper gen_ordering_tests
#        ordered comparison operators for real valued tests
#    helper gen_elementop_tests
#        element-wise matrix binary operators, including scalar-matrix ops.
#        horizontal/vertical concatenation are here as well.
#    helper gen_matrixop_tests
#        rectangular matrix binary operators: * and / --- \ fails for now
#    helper gen_unaryop_tests
#        functions and operators which transform a single matrix
#    gen_scalar_tests
#        element ops for real and complex scalar and sparse
#    gen_rectangular_tests
#        unary, element, and matrix tests for a and full/sparse b
#    gen_square_tests
#        operations which require square matrices: lu, inv, \
#        A square non-singular matrix is defined from the rectangular
#        inputs A and B.
#    gen_assembly_tests
#        test for sparse constructors with 'sum' vs. 'unique'
#    gen_select_tests
#        indexing tests

case $1 in
    random) preset=false ;;
    preset) preset=true ;;
    '') preset=true ;;
    *) echo "buildtest.sh random|preset" && exit 1 ;;
esac

if $preset; then
    TESTS=sptest.m
else
    TESTS=sprandomtest.m
fi

# create initial file
cat >$TESTS <<EOF
## THIS IS AN AUTOMATICALLY GENERATED FILE --- DO NOT EDIT ---
## instead modify buildtests.sh to generate the tests that you want.
EOF


# define all functions


# =======================================================
# Section separator

function gen_section {
cat >>$TESTS <<EOF

# ==============================================================

EOF
}


# =======================================================
# Specific preset tests

# =======================================================
# If a sparse operation yields zeros, then those elements 
# of the returned sparse matrix should be eaten.
function gen_eat_zeros {
cat >>$TESTS <<EOF
%% Make sure newly introduced zeros get eaten
%!assert(nnz(sparse([bf,bf,1]).^realmax),1);
%!assert(nnz(sparse([1,bf,bf]).^realmax),1);
%!assert(nnz(sparse([bf,bf,bf]).^realmax),0); 

%!assert(nnz(sparse([bf;bf;1]).^realmax),1);
%!assert(nnz(sparse([1;bf;bf]).^realmax),1);
%!assert(nnz(sparse([0.5;bf;bf]).^realmax),0);

%!#assert(nnz(sparse([bf,bf,1])*realmin),1); # fails
%!#assert(nnz(sparse([1,bf,bf])*realmin),1); # fails
%!#assert(nnz(sparse([bf,bf,bf])*realmin),0); # fails

%!#assert(nnz(sparse([bf;bf;1])*realmin),1); # fails
%!#assert(nnz(sparse([1;bf;bf])*realmin),1); # fails
%!#assert(nnz(sparse([bf;bf;bf])*realmin),0); # fails

EOF
}

function gen_specific {
cat >>$TESTS <<EOF

%!test # segfault test from edd@debian.org
%! n = 510;
%! sparse(kron((1:n)', ones(n,1)), kron(ones(n,1), (1:n)'), ones(n)); 

%% segfault tests from Fabian@isas-berlin.de
%!assert(spinv(sparse([1,1;1,1+i])),[1-1i,1i;1i,-1i],10*eps);
%!error spinv( sparse( [1,1;1,1]   ) );
%!error spinv( sparse( [0,0;0,1]   ) );
%!error spinv( sparse( [0,0;0,1+i] ) );
%!error spinv( sparse( [0,0;0,0]   ) );
%!error splu( sparse( [1,1;1,1]   ) );
%!error splu( sparse( [0,0;0,1]   ) );
%!error splu( sparse( [0,0;0,1+i] ) );
%!error splu( sparse( [0,0;0,0]   ) );
%!test
%! [l,u]=splu(sparse([1,1;1,1+i]));
%! assert(l,sparse([1,2,2],[1,1,2],1),10*eps);
%! assert(u,sparse([1,1,2],[1,2,2],[1,1,1i]),10*eps);

%% error handling in constructor
%!error sparse(1,[2,3],[1,2,3]);
%!error sparse([1,1],[1,1],[1,2],3,3,'bogus');
%!error sparse([1,3],[1,-4],[3,5],2,2);
%!error sparse([1,3],[1,-4],[3,5i],2,2);
%!error sparse(-1,-1,1);
EOF
}


function gen_specific_tests {
    gen_section
    gen_specific
    gen_section
    echo '%!shared bf' >> $TESTS
    echo '%!test bf=realmin;' >> $TESTS
    gen_eat_zeros
    echo '%!test bf=realmin+realmin*1i;' >> $TESTS
    gen_eat_zeros
    cat >>$TESTS <<EOF
%!assert(nnz(sparse([-1,realmin,realmin]).^1.5),1);
%!assert(nnz(sparse([-1,realmin,realmin,1]).^1.5),2);

%!assert(nnz(sparse(1,1,0)),0); # Make sure scalar v==0 doesn't confuse matters
%!assert(nnz(sparse(eye(3))*0),0);
%!assert(nnz(sparse(eye(3))-sparse(eye(3))),0);

%!assert(sparse(eye(3))/0,sparse([1:3],[1:3],Inf));

EOF
}


# =======================================================
# Main function definition

function gen_function {
    if $preset; then
	cat >>$TESTS <<EOF
##
## sptest
##
##    run preset sparse tests.  All should pass.
function [passes,tests] = sptest
  disp('writing test output to sptest.log');
  test('sptest','normal','sptest.log');
endfunction

EOF
    else
	cat >>$TESTS <<EOF
##
## sprandomtest
##
##  total_passes=0; total_tests=0;
##  for i=1:10
##     [passes,tests] = sprandomtest;
##    total_passes += passes;
##    total_tests += tests;
##  end
##  The test log is appended to sprandomtest.log
function [passes,total] = sprandomtest
  warning("untested --- fix the source in buildtests.sh");
  disp('appending test output to sprandomtest.log');
  fid = fopen('sprandomtest.log','at');
  [passes, total] = test('sprandomtest','normal',fid);
  fclose(fid);
endfunction

EOF
    fi
    
}


# =======================================================
# matrix ops

# test ordered comparisons: uses as,af,bx,bf
function gen_ordering_tests {
    cat >>$TESTS <<EOF
%% real values can be ordered (uses as,af)
%!assert(as<=bx,af<=bf)
%!assert(bx<=as,bf<=af)
%!assert(as>=bx,af>=bf)
%!assert(bx>=as,bf>=af)
%!assert(as<bx,af<bf)
%!assert(bx<as,bf<af)
%!assert(as>bx,af>bf)
%!assert(bx>as,bf>af)

EOF
}

# test element-wise binary operations: uses as,af,bx,bf
function gen_elementop_tests {
    cat >>$TESTS <<EOF
%% Elementwise binary tests (uses as,af,bx,bf)
%!assert(as==bx,af==bf)
%!assert(bx==as,bf==af)
%!assert(as!=bx,af!=bf)
%!assert(bx!=as,bf!=af)
%!assert(as+bx,af+bf)
%!assert(bx+as,bf+af)
%!assert(as-bx,af-bf)
%!assert(bx-as,bf-af)
%!assert(as.*bx,af.*bf)
%!assert(bx.*as,bf.*af)
%!assert(as./bx,af./bf,100*eps)
%!assert(bx.\as,bf.\af,100*eps)
%!test
%! sv = as.^bx;
%! fv = af.^bf;
%! idx = find(af~=0);
%! assert(sv(:)(idx),fv(:)(idx),100*eps)

EOF
}

# test matrix-matrix operations: uses as,af,bx,bf
function gen_matrixop_tests {
    cat >>$TESTS <<EOF
%% Matrix-matrix operators (uses af,as,bx,bf)
%!assert(as*bx',af*bf')
%!assert(bx'*as,bf'*af)
%!assert(as/bx,af/bf,100*eps)
%!#assert(bx\as,bf\af,100*eps) # fails (\ seg-faults for non-square)

EOF
}

# test matrix operations: uses as,af
function gen_unaryop_tests {
    cat >>$TESTS <<EOF
%% Unary matrix tests (uses af,as)
%!assert(is_sparse(as),1)
%!assert(is_sparse(af),0)
%!assert(is_real_sparse(af),0)
%!assert(is_complex_sparse(af),0)
%!assert(spsum(as),sum(af))
%!assert(spsum(as,1),sum(af,1))
%!assert(spsum(as,2),sum(af,2))
%!assert(as==as)
%!assert(as==af)
%!assert(af==as)
%!test
%! [ii,jj,vv,nr,nc] = spfind(as);
%! assert(af,full(sparse(ii,jj,vv,nr,nc)));
%!assert(nnz(as),sum(af(:)!=0))
%!assert(nnz(as),nnz(af))
%!assert(is_real_sparse(spabs(as)))
%!assert(is_real_sparse(spreal(as)))
%!assert(is_real_sparse(spimag(as)))
%!assert(is_sparse(as.'))
%!assert(is_sparse(as'))
%!assert(is_sparse(-as))
%!assert(!is_sparse(~as))
%!assert(spabs(as),abs(af))
%!assert(spreal(as),real(af))
%!assert(spimag(as),imag(af))
%!assert(as.', af.');
%!assert(as',  af');
%!assert(-as, -af);
%!assert(~as, ~af); # fails on 2.1.52
%!error [i,j]=size(af);as(i-1,j+1);
%!error [i,j]=size(af);as(i+1,j-1);
%!test
%! [Is,Js,Vs] = spfind(as);
%! [If,Jf,Vf] = find(af);
%! assert(Is,If);
%! assert(Js,Jf);
%! assert(Vs,Vf);
%!error as(0,1);
%!error as(1,0);
%!assert(spfind(as),find(af))
%!test
%! [i,j,v] = spfind(as);
%! [m,n] = size(as);
%! x = sparse(i,j,v,m,n);
%! assert(x,as);
%!test
%! [i,j,v,m,n] = spfind(as);
%! x = sparse(i,j,v,m,n);
%! assert(x,as);
%!assert(issparse(sphcat(as,as)));
%!assert(issparse(spvcat(as,as)));
%!assert(sphcat(as,as), [af,af]);
%!assert(spvcat(as,as), [af;af]);
%!assert(sphcat(as,as,as), [af,af,af]);
%!assert(spvcat(as,as,as), [af;af;af]);

EOF
}

# operations which require square matrices.
function gen_square_tests {
    cat >>$TESTS <<EOF
%!test ;# permuted LU
%! [L,U] = splu(bx);
%! assert(L*U,bx,1e-10);

%!test ;# simple LU + permutations
%! [L,U,pr,pc] = splu(bx);
%! assert(pr'*L*U*pc,bx,1e-10);
%! # triangularity
%! [i,j,v]=spfind(L);
%! assert(i-j>=0);
%! [i,j,v]=spfind(U);
%! assert(j-i>=0);

%!test ;# inverse
%! assert(spinv(bx)*bx,eye(rows(bx)),1e-10);

%!#assert(bx\as,bf\af,100*eps); # fails
%!#assert(bf\as,bf\af,100*eps); # fails
%!#assert(bx\af,bf\af,100*eps); # fails

EOF
}

# test scalar operations: uses af and real scalar bf; modifies as,bx
function gen_scalar_tests {
    echo '%!test as=sparse(af);' >> $TESTS
    echo '%!test bx=bf;' >> $TESTS
    gen_elementop_tests
    echo '%!test bx=bf=bf+1i;' >>$TESTS
    gen_elementop_tests
}

# test matrix operations: uses af and bf; modifies as,bx
function gen_rectangular_tests {
    echo '%!test as=sparse(af);' >> $TESTS
    echo '%!test bx=bf;' >>$TESTS
    gen_unaryop_tests
    gen_elementop_tests
    gen_matrixop_tests
    echo '%!test bx=sparse(bf);' >>$TESTS
    gen_elementop_tests
    gen_matrixop_tests
}


# =======================================================
# sparse assembly tests

function gen_assembly_tests {
echo >>$TESTS <<EOF
%%Assembly tests
%!test
%! m=max([m;r(:)]);
%! n=max([n;c(:)]);
%! funiq=fsum=zeros(m,n);
%! funiq( r(:) + (max(r(:))-1)*(c(:)-1) ) = ones(size(r(:)));
%! for k=1:length(r), fsum(r(k),c(k)) += 1; end
%!assert(sparse(r,c,1),fsum(1:max(r),1:max(c)));
%!assert(sparse(r,c,1,'sum'),fsum(1:max(r),1:max(x)));
%!assert(sparse(r,c,1,'unique'),funiq(1:max(r),1:max(c)));
%!assert(sparse(r,c,1,m,n),fsum);
%!assert(sparse(r,c,1,m,n,'sum'),fsum);
%!assert(sparse(r,c,1,m,n,'unique'),funiq);

%!assert(sparse(r,c,1i),fsum(1:max(r),1:max(c))*1i);
%!assert(sparse(r,c,1i,'sum'),fsum(1:max(r),1:max(x))*1i);
%!assert(sparse(r,c,1i,'unique'),funiq(1:max(r),1:max(c))*1i);
%!assert(sparse(r,c,1i,m,n),fsum*1i);
%!assert(sparse(r,c,1i,m,n,'sum'),fsum*1i);
%!assert(sparse(r,c,1i,m,n,'unique'),funiq*1i);

EOF
}

# =======================================================
# sparse selection tests

function gen_select_tests {
    cat >>$TESTS <<EOF
%!test as=sparse(af);

%% Point tests
%!test idx=ridx(:)+rows(as)*(cidx(:)-1);
%!#assert(issparse(as(idx))); # fails (not yet implemented)
%!assert(as(idx),af(idx));
%!#assert(as(idx'),af(idx')); # fails (not yet implemented)
%!#assert(as([idx,idx]),af([idx,idx])); # fails (not yet implemented)
%!#assert(as(reshape([idx;idx],[1,length(idx),2])),af([idx',idx'])); # fails

%% Slice tests
%!assert(as(ridx,cidx),af(ridx,cidx))
%!assert(as(ridx,:), af(ridx,:))
%!assert(as(:,cidx), af(:,cidx))
%!assert(as(:,:), af(:,:))

%% Test 'end' keyword
%!#assert(as(end),af(end)) # fails (not yet implemented)
%!#assert(as(1,end), af(1,end)) # fails (not yet implemented)
%!#assert(as(end,1), af(end,1)) # fails (not yet implemented)
%!#assert(as(end,end), af(end,end))
%!#assert(as(2:end,2:end), af(2:end,2:end))
%!#assert(as(1:end-1,1:end-1), af(1:end-1,1:end-1))
EOF
}

# =======================================================
# sparse save and load tests

function gen_save_tests {
    cat >>$TESTS <<EOF
%!test # save ascii
%! savefile= tmpnam();
%! mark_for_deletion( savefile );
%! as_save=as; save(savefile,'bf','as_save','af');
%! clear as_save;
%! load(savefile,'as_save');
%! assert(as_save,af);
%!test # save binary
%! savefile= tmpnam();
%! mark_for_deletion( savefile );
%! as_save=as; save('-binary',savefile,'bf','as_save','af');
%! clear as_save;
%! load(savefile,'as_save');
%! assert(as_save,af);
EOF
}

# =============================================================
# Putting it all together: defining the combined tests


# initial function
gen_function
gen_section

# specific tests
if $preset; then 
    gen_specific_tests
    gen_section
fi

# scalar operations
echo '%!shared as,af,bx,bf' >> $TESTS
if $preset; then
    echo '%!test af=[1+1i,2-1i,0,0;0,0,0,3+2i;0,0,0,4];' >> $TESTS
    echo '%!test bf=3;' >>$TESTS
else
    cat >>$TESTS <<EOF
%!test
%! % generate m,n from 1 to <5000
%! m=floor(lognormal_rnd(8,2)+1);
%! n=floor(lognormal_rnd(8,2)+1);
%! as=sprandn(m,n,0.3); af = full(as+1i*sprandn(as));
%! bf = randn;
EOF
fi

gen_scalar_tests
gen_section

# rectangular operations
if $preset; then
    echo '%!test af=[1+1i,2-1i,0,0;0,0,0,3+2i;0,0,0,4];' >> $TESTS
    echo '%!test bf=[0,1-1i,0,0;2+1i,0,0,0;3-1i,2+3i,0,0];' >> $TESTS
else
    cat >>$TESTS <<EOF
%!test
%! as=sprandn(m,n,0.3); af = full(as+1i*sprandn(as));
%! bs=sprandn(m,n,0.3); bf = full(bs+1i*sprandn(bs));
EOF
fi

gen_rectangular_tests
gen_section
gen_save_tests
echo '%!test bf=real(bf);' >> $TESTS
gen_rectangular_tests
gen_section
echo '%!test af=real(af);' >> $TESTS
gen_rectangular_tests
gen_section
gen_save_tests
echo '%!test bf=bf+1i*(bf~=0);' >> $TESTS
gen_rectangular_tests
gen_section

# square operations
if $preset; then
    echo '%!test af=[1+1i,2-1i,0,0;0,0,0,3+2i;0,0,0,4];' >> $TESTS
    echo '%!test bf=[0,1-1i,0,0;2+1i,0,0,0;3-1i,2+3i,0,0];' >> $TESTS
else
    cat >>$TESTS <<EOF
%!test
%! as=sprandn(m,n,0.3); af = full(as+1i*sprandn(as));
%! bs=sprandn(m,n,0.3); bf = full(bs+1i*sprandn(bs));
EOF
fi

cat >>$TESTS <<EOF
%!test ;# invertible matrix
%! bf=af'*bf+max(abs([af(:);bf(:)]))*sparse(eye(columns(as)));
%! bx=sparse(bf);

EOF

gen_square_tests
gen_section
echo '%!test bf=real(bf);' >> $TESTS
gen_square_tests
gen_section
echo '%!test af=real(af);' >> $TESTS
gen_square_tests
gen_section
echo '%!test bf=bf+1i*(bf~=0);' >> $TESTS
gen_square_tests
gen_section

# assembly tests
echo '%!shared r,c,m,n,fsum,funiq' >>$TESTS
if $use_preset; then
    cat >>$TESTS <<EOF
%!test
%! r=[1,1,2,1,2,3];
%! c=[2,1,1,1,2,1];
%! m=n=0;
EOF
else
    cat >>$TESTS <<EOF
%!test
%! % generate m,n from 1 to <5000
%! m=floor(lognormal_rnd(8,2)+1);
%! n=floor(lognormal_rnd(8,2)+1);
%! nz=ceil((m+n)/2);
%! r=floor(rand(5,nz)*n)+1;
%! c=floor(rand(5,nn)*m)+1;
EOF
fi
gen_assembly_tests #includes real and complex tests
gen_section

# slicing tests
echo '%!shared ridx,cidx,idx,as,af' >>$TESTS
if $use_preset; then
    cat >>$TESTS <<EOF
%!test
%! af=[1+1i,2-1i,0,0;0,0,0,3+2i;0,0,0,4];
%! ridx=[1,3]; cidx=[2,3];
EOF
else
    cat >>$TESTS <<EOF
%!test
%! % generate m,n from 1 to <5000
%! m=floor(lognormal_rnd(8,2)+1);
%! n=floor(lognormal_rnd(8,2)+1);
%! as=sprandn(m,n,0.3); af = full(as+1i*sprandn(as));
%! ridx = ceil(m*rand(1,ceil(rand*m))
%! cidx = ceil(n*rand(1,ceil(rand*n))
EOF
fi
gen_select_tests
echo '%!test af=real(af);' >> $TESTS
gen_select_tests
gen_section

