%% usage: ndims(a)
%%
%% Return length(size(a)), the number of dimensions of array a.  This
%% exists for Matlab compatibility; in Octave it's always equal to 2.

function ret = ndims(a)
    if (nargin != 1)
        usage('ndims requires a single argument')
    end
    ret = length(size(a));
end

