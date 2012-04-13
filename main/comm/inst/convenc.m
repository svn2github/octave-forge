## Copyright (C) 2012 Tony Richardson <richardson.tony@gmailcom>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

% -- Function File: convenv(m, G, k)
%    Compute the output of an (n, k, L) convolutional encoder with vector input
%    m and matrix of generator polynomials G.
%
%   The input vector m can be of arbitrary length.   G is a matrix with n rows
%   and k*(L+1) columns.  The rows of G are the generator polynomials for each
%   of the n output bits (per k input bits).
%
%   The output is a vector whose length is n*floor([length(m)+k*(L+1)-1]/k).
%   With two inputs, k is assumed to be equal to 1.
%
%   Example 1: Compute the output from a (2, 1, 2)  convolutional encoder
%   with generator polynomials g1 = [ 1 1 1 ] and g2 = [ 1 0 1 ]
%   when the input message is m = [ 1 1 0 1 1 1 0 0 1 0 0 0 ]
%
%   x = convenc(m, [g1; g2])
%   x = 1101010001100111111011000000
%
%   Example 2: Compute the output from a (3, 2, 1) conv encoder with
%   generator polynomials g1 = [ 1 0 1 1 ], g2 = [ 1 1 0 1 ] and
%   g3 = [ 1 0 1 0 ] when the input is m = [ 0   1   1   0   0   0   1   1 ]
%
%   x = convenc(m, [g1; g2; g3], 2)
%   x = 111 111 110 101
%
%   Note: This function is not compatible with Matlab's convenc()

function x = convenc(m, G, k=1)
	% Use conv2 to do repeated 1d convolutions of m with each row of G. 
	% rem is used to transform the standard convolution result to one
	% which uses modulo-2 addition.  Only cols with index a mult. of k 
	% are in the actual enc. output

	x = rem(conv2(1, m(:)', G),2)(:,!rem(1:numel(m),k))(:)';
end
