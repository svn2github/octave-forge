## Copyright (C) 2007 Lukasz Komsta, http://www.komsta.net/
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## Critical values and p-values for Dixon tests
## 
## Description:
## 
##      Approximated quantiles (critical values) and distribution function
##      (giving p-values) for Dixon tests for outliers.
## 
## Usage:
## 
##      [q]=dixoninv(p, n, type, rev) 
## 
## Arguments:
## 
##        p: vector of probabilities. 
## 
##        n: length of sample. 
## 
##     type: integer value: 10, 11, 12, 20, or 21. For description see
##           'dixontest'. 
## 
##      rev: function 'dixoninv' with this parameter set to TRUE acts as
##           'dixoncdf' to omit the repetition of code. 'dixoncdf' is the wrapper.
## 
## Details:
## 
##      This function is based on tabularized Dixon distribution, given by
##      Dixon (1950) and corrected by Rorabacher (1991). Continuity is
##      reached due to smart interpolation using 'qtable' function. By
##      now, numerical procedure to obtain these values for n>3 is not
##      known.
## 
## Value:
## 
##      Critical value or p-value (vector).
## 
## Author(s):
## 
##      Lukasz Komsta, ported from R package "outliers".
##	See R News, 6(2):10-13, May 2006
## 
## References:
## 
##      Dixon, W.J. (1950). Analysis of extreme values. Ann. Math. Stat.
##      21, 4, 488-506.
## 
##      Dixon, W.J. (1951). Ratios involving extreme values. Ann. Math.
##      Stat. 22, 1, 68-78.
## 
##      Rorabacher, D.B. (1991). Statistical Treatment for Rejection of
##      Deviant Values: Critical Values of Dixon Q Parameter and Related
##      Subrange Ratios at the 95 percent Confidence Level. Anal. Chem.
##      83, 2, 139-146.
## 
## 


function [q]=dixoninv(p, n, type, rev) 

	if nargin<4
		rev=0;
	end
	if nargin<3
		type=10;
	end

	if (type == 10 | type == 0) & (n < 3 | n > 30) 
		error("Sample size must be in range 3-30");
	elseif (type == 11 & (n < 4 | n > 30))
		error("Sample size must be in range 4-30");
    	elseif (type == 12 & (n < 5 | n > 30))
		error("Sample size must be in range 5-30");
	elseif (type == 20 & (n < 4 | n > 30)) 
		error("Sample size must be in range 4-30");
	elseif (type == 21 & (n < 5 | n > 30)) 
		error("Sample size must be in range 5-30");
	elseif (type == 22 & (n < 6 | n > 30)) 
		error("Sample size must be in range 6-30");
	end

	if ~any([0 10 11 12 20 21 22] == type) 
		error("Incorrect type");
	elseif (type == 0)
		if (n <= 7) 
            		type=10;
        	elseif (n > 7 & n <= 10) 
			type=11;
        	elseif (n > 10 & n <= 13) 
			type=21;
	        else
		        type=22;
		end
	end

    pp = [0.005, 0.01, 0.02, 0.025, 0.05, 0.1, 0.2, 0.3, 0.4, ...
        0.5, 0.6, 0.7, 0.8, 0.9, 0.95];
    q10 =[NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
        NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
        NA, NA, NA, NA, 0.994, 0.988, 0.976, 0.97, 0.941, 0.886, ...
        0.781, 0.684, 0.591, 0.5, 0.409, 0.316, 0.219, 0.114, ...
        0.059, 0.926, 0.889, 0.846, 0.829, 0.765, 0.679, 0.56, ...
        0.471, 0.394, 0.324, 0.257, 0.193, 0.13, 0.065, 0.033, ...
        0.821, 0.78, 0.729, 0.71, 0.642, 0.557, 0.451, 0.373, ...
        0.308, 0.25, 0.196, 0.146, 0.097, 0.048, 0.023, 0.74, ...
        0.698, 0.644, 0.625, 0.56, 0.482, 0.386, 0.318, 0.261, ...
        0.21, 0.164, 0.121, 0.079, 0.038, 0.018, 0.68, 0.637, ...
        0.586, 0.568, 0.507, 0.434, 0.344, 0.281, 0.23, 0.184, ...
        0.143, 0.105, 0.068, 0.032, 0.016, 0.634, 0.59, 0.543, ...
        0.526, 0.468, 0.399, 0.314, 0.255, 0.208, 0.166, 0.128, ...
        0.094, 0.06, 0.029, 0.014, 0.598, 0.555, 0.51, 0.493, ...
        0.437, 0.37, 0.29, 0.234, 0.191, 0.152, 0.118, 0.086, ...
        0.055, 0.026, 0.013, 0.568, 0.527, 0.483, 0.466, 0.412, ...
        0.349, 0.273, 0.219, 0.178, 0.142, 0.11, 0.08, 0.051, ...
        0.025, 0.012, 0.542, 0.502, 0.46, 0.444, 0.392, 0.332, ...
        0.259, 0.208, 0.168, 0.133, 0.103, 0.074, 0.048, 0.023, ...
        0.011, 0.522, 0.482, 0.441, 0.426, 0.376, 0.318, 0.247, ...
        0.197, 0.16, 0.126, 0.097, 0.07, 0.047, 0.022, 0.011, ...
        0.503, 0.465, 0.425, 0.41, 0.361, 0.305, 0.237, 0.188, ...
        0.153, 0.12, 0.092, 0.067, 0.043, 0.021, 0.01, 0.488, ...
        0.45, 0.411, 0.396, 0.349, 0.294, 0.228, 0.181, 0.147, ...
        0.115, 0.088, 0.064, 0.041, 0.02, 0.01, 0.475, 0.438, ...
        0.399, 0.384, 0.338, 0.285, 0.22, 0.175, 0.141, 0.111, ...
        0.085, 0.062, 0.04, 0.019, 0.01, 0.463, 0.426, 0.388, ...
        0.374, 0.329, 0.277, 0.213, 0.169, 0.136, 0.107, 0.082, ...
        0.06, 0.039, 0.019, 0.009, 0.452, 0.416, 0.379, 0.365, ...
        0.32, 0.269, 0.207, 0.165, 0.132, 0.104, 0.08, 0.058, ...
        0.038, 0.018, 0.009, 0.442, 0.407, 0.37, 0.356, 0.313, ...
        0.263, 0.202, 0.16, 0.128, 0.101, 0.078, 0.056, 0.036, ...
        0.018, 0.009, 0.433, 0.398, 0.363, 0.349, 0.306, 0.258, ...
        0.197, 0.157, 0.125, 0.098, 0.076, 0.055, 0.036, 0.017, ...
        0.008, 0.425, 0.391, 0.356, 0.342, 0.3, 0.252, 0.193, ...
        0.153, 0.122, 0.096, 0.074, 0.053, 0.035, 0.017, 0.008, ...
        0.418, 0.384, 0.35, 0.337, 0.295, 0.247, 0.189, 0.15, ...
        0.119, 0.094, 0.072, 0.052, 0.034, 0.016, 0.008, 0.411, ...
        0.378, 0.344, 0.331, 0.29, 0.242, 0.185, 0.147, 0.117, ...
        0.092, 0.071, 0.051, 0.033, 0.016, 0.008, 0.404, 0.372, ...
        0.338, 0.326, 0.285, 0.238, 0.182, 0.144, 0.115, 0.09, ...
        0.069, 0.05, 0.033, 0.016, 0.008, 0.399, 0.367, 0.333, ...
        0.321, 0.281, 0.234, 0.179, 0.142, 0.113, 0.089, 0.068, ...
        0.049, 0.032, 0.016, 0.008, 0.393, 0.362, 0.329, 0.317, ...
        0.277, 0.23, 0.176, 0.139, 0.111, 0.088, 0.067, 0.048, ...
        0.032, 0.015, 0.008, 0.388, 0.357, 0.324, 0.312, 0.273, ...
        0.227, 0.173, 0.137, 0.109, 0.086, 0.066, 0.047, 0.031, ...
        0.015, 0.007, 0.384, 0.353, 0.32, 0.308, 0.269, 0.224, ...
        0.171, 0.135, 0.108, 0.085, 0.065, 0.047, 0.031, 0.015, ...
        0.007, 0.38, 0.349, 0.316, 0.305, 0.266, 0.22, 0.168, ...
        0.133, 0.106, 0.084, 0.064, 0.046, 0.03, 0.015, 0.007, ...
        0.376, 0.345, 0.312, 0.301, 0.263, 0.218, 0.166, 0.131, ...
        0.105, 0.083, 0.063, 0.046, 0.03, 0.014, 0.007, 0.372, ...
        0.341, 0.309, 0.298, 0.26, 0.215, 0.164, 0.13, 0.103, ...
        0.082, 0.062, 0.045, 0.029, 0.014, 0.007];
    q11 = [NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
        NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
        NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
        NA, NA, NA, NA, NA, 0.995, 0.991, 0.981, 0.977, 0.955, ...
        0.91, 0.822, 0.737, 0.648, 0.554, 0.459, 0.362, 0.25, ...
        0.131, 0.069, 0.937, 0.916, 0.876, 0.863, 0.807, 0.728, ...
        0.615, 0.524, 0.444, 0.369, 0.296, 0.224, 0.151, 0.078, ...
        0.039, 0.839, 0.805, 0.763, 0.748, 0.689, 0.609, 0.502, ...
        0.42, 0.35, 0.288, 0.227, 0.169, 0.113, 0.056, 0.028, ...
        0.782, 0.74, 0.689, 0.673, 0.61, 0.53, 0.432, 0.359, ...
        0.298, 0.241, 0.189, 0.14, 0.093, 0.045, 0.022, 0.725, ...
        0.683, 0.631, 0.615, 0.554, 0.479, 0.385, 0.318, 0.26, ...
        0.21, 0.164, 0.121, 0.079, 0.037, 0.019, 0.677, 0.635, ...
        0.587, 0.57, 0.512, 0.441, 0.352, 0.288, 0.236, 0.189, ...
        0.148, 0.107, 0.07, 0.033, 0.016, 0.639, 0.597, 0.551, ...
        0.534, 0.477, 0.409, 0.325, 0.265, 0.216, 0.173, 0.134, ...
        0.098, 0.063, 0.03, 0.014, 0.606, 0.566, 0.521, 0.505, ...
        0.45, 0.385, 0.305, 0.248, 0.202, 0.161, 0.124, 0.09, ...
        0.058, 0.028, 0.013, 0.58, 0.541, 0.498, 0.481, 0.428, ...
        0.367, 0.289, 0.234, 0.19, 0.15, 0.116, 0.084, 0.055, ...
        0.026, 0.012, 0.558, 0.52, 0.477, 0.461, 0.41, 0.35, ...
        0.275, 0.222, 0.18, 0.142, 0.109, 0.079, 0.052, 0.025, ...
        0.012, 0.539, 0.502, 0.46, 0.445, 0.395, 0.336, 0.264, ...
        0.212, 0.171, 0.135, 0.104, 0.075, 0.049, 0.024, 0.011, ...
        0.522, 0.486, 0.445, 0.43, 0.381, 0.323, 0.253, 0.203, ...
        0.164, 0.129, 0.099, 0.072, 0.047, 0.023, 0.011, 0.508, ...
        0.472, 0.432, 0.417, 0.369, 0.313, 0.244, 0.196, 0.158, ...
        0.124, 0.095, 0.096, 0.045, 0.022, 0.011, 0.495, 0.46, ...
        0.42, 0.406, 0.359, 0.303, 0.236, 0.19, 0.152, 0.119, ...
        0.092, 0.067, 0.044, 0.021, 0.01, 0.484, 0.449, 0.41, ...
        0.396, 0.349, 0.295, 0.229, 0.184, 0.148, 0.116, 0.089, ...
        0.065, 0.042, 0.02, 0.01, 0.473, 0.439, 0.4, 0.386, 0.341, ...
        0.288, 0.223, 0.179, 0.143, 0.112, 0.087, 0.063, 0.041, ...
        0.02, 0.01, 0.464, 0.43, 0.392, 0.379, 0.334, 0.282, ...
        0.218, 0.174, 0.139, 0.11, 0.084, 0.061, 0.04, 0.019, ...
        0.01, 0.455, 0.421, 0.384, 0.371, 0.327, 0.276, 0.213, ...
        0.17, 0.136, 0.107, 0.082, 0.059, 0.039, 0.019, 0.009, ...
        0.446, 0.414, 0.377, 0.364, 0.32, 0.27, 0.208, 0.166, ...
        0.132, 0.104, 0.081, 0.058, 0.038, 0.018, 0.009, 0.439, ...
        0.407, 0.371, 0.357, 0.314, 0.265, 0.204, 0.163, 0.13, ...
        0.102, 0.079, 0.056, 0.037, 0.018, 0.009, 0.432, 0.4, ...
        0.365, 0.352, 0.309, 0.26, 0.2, 0.16, 0.127, 0.1, 0.077, ...
        0.055, 0.036, 0.018, 0.009, 0.426, 0.394, 0.359, 0.346, ...
        0.304, 0.255, 0.197, 0.156, 0.124, 0.098, 0.076, 0.054, ...
        0.036, 0.017, 0.009, 0.42, 0.389, 0.354, 0.341, 0.299, ...
        0.25, 0.193, 0.154, 0.122, 0.096, 0.074, 0.053, 0.035, ...
        0.017, 0.008, 0.414, 0.383, 0.349, 0.337, 0.295, 0.246, ...
        0.19, 0.151, 0.12, 0.095, 0.073, 0.052, 0.034, 0.017, ...
        0.008, 0.409, 0.378, 0.344, 0.332, 0.291, 0.243, 0.188, ...
        0.149, 0.118, 0.093, 0.072, 0.051, 0.034, 0.016, 0.008, ...
        0.404, 0.374, 0.34, 0.328, 0.287, 0.239, 0.185, 0.146, ...
        0.116, 0.092, 0.07, 0.051, 0.033, 0.016, 0.008, 0.399, ...
        0.369, 0.336, 0.324, 0.283, 0.236, 0.182, 0.144, 0.115, ...
        0.09, 0.069, 0.05, 0.032, 0.016, 0.008];
    q12 = [NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
        NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
        NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
        NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
        NA, NA, NA, NA, NA, NA, 0.996, 0.992, 0.984, 0.98, 0.96, ...
        0.919, 0.838, 0.755, 0.669, 0.579, 0.483, 0.381, 0.268, ...
        0.143, 0.074, 0.951, 0.925, 0.891, 0.878, 0.824, 0.745, ...
        0.635, 0.545, 0.465, 0.39, 0.316, 0.24, 0.165, 0.088, ...
        0.049, 0.875, 0.836, 0.791, 0.773, 0.712, 0.636, 0.528, ...
        0.445, 0.374, 0.307, 0.245, 0.183, 0.123, 0.064, 0.031, ...
        0.797, 0.76, 0.708, 0.692, 0.632, 0.557, 0.456, 0.382, ...
        0.317, 0.258, 0.203, 0.152, 0.101, 0.056, 0.025, 0.739, ...
        0.702, 0.656, 0.639, 0.58, 0.504, 0.409, 0.339, 0.27, ...
        0.227, 0.177, 0.13, 0.086, 0.044, 0.021, 0.694, 0.655, ...
        0.61, 0.594, 0.537, 0.464, 0.373, 0.308, 0.258, 0.204, ...
        0.158, 0.116, 0.075, 0.038, 0.019, 0.658, 0.619, 0.575, ...
        0.559, 0.502, 0.431, 0.345, 0.283, 0.232, 0.187, 0.145, ...
        0.106, 0.069, 0.035, 0.017, 0.629, 0.59, 0.546, 0.529, ...
        0.473, 0.406, 0.324, 0.265, 0.217, 0.174, 0.135, 0.098, ...
        0.063, 0.032, 0.016, 0.602, 0.564, 0.521, 0.505, 0.451, ...
        0.387, 0.307, 0.25, 0.204, 0.163, 0.126, 0.092, 0.059, ...
        0.03, 0.015, 0.58, 0.542, 0.501, 0.485, 0.432, 0.369, ...
        0.292, 0.237, 0.193, 0.153, 0.118, 0.086, 0.055, 0.028, ...
        0.014, 0.56, 0.523, 0.482, 0.467, 0.416, 0.354, 0.28, ...
        0.226, 0.184, 0.146, 0.112, 0.082, 0.053, 0.026, 0.013, ...
        0.544, 0.508, 0.467, 0.452, 0.401, 0.341, 0.269, 0.217, ...
        0.177, 0.139, 0.107, 0.078, 0.05, 0.025, 0.013, 0.529, ...
        0.493, 0.453, 0.438, 0.388, 0.33, 0.259, 0.209, 0.17, ...
        0.134, 0.103, 0.075, 0.048, 0.024, 0.012, 0.516, 0.48, ...
        0.44, 0.426, 0.377, 0.32, 0.251, 0.202, 0.163, 0.129, ...
        0.099, 0.072, 0.047, 0.023, 0.012, 0.504, 0.469, 0.429, ...
        0.415, 0.367, 0.311, 0.243, 0.196, 0.157, 0.125, 0.096, ...
        0.069, 0.045, 0.022, 0.011, 0.493, 0.458, 0.419, 0.405, ...
        0.358, 0.303, 0.237, 0.191, 0.153, 0.121, 0.093, 0.067, ...
        0.044, 0.022, 0.011, 0.483, 0.449, 0.41, 0.396, 0.349, ...
        0.296, 0.231, 0.186, 0.148, 0.118, 0.09, 0.065, 0.042, ...
        0.021, 0.01, 0.474, 0.44, 0.402, 0.388, 0.342, 0.29, ...
        0.225, 0.181, 0.145, 0.114, 0.088, 0.063, 0.041, 0.02, ...
        0.01, 0.465, 0.432, 0.394, 0.381, 0.336, 0.284, 0.22, ...
        0.176, 0.141, 0.112, 0.086, 0.062, 0.04, 0.02, 0.01, ...
        0.457, 0.423, 0.387, 0.374, 0.33, 0.278, 0.216, 0.173, ...
        0.138, 0.109, 0.084, 0.06, 0.039, 0.019, 0.01, 0.45, ...
        0.417, 0.381, 0.368, 0.324, 0.273, 0.212, 0.169, 0.135, ...
        0.107, 0.082, 0.059, 0.038, 0.019, 0.009, 0.443, 0.411, ...
        0.375, 0.362, 0.319, 0.268, 0.208, 0.166, 0.132, 0.105, ...
        0.08, 0.058, 0.037, 0.019, 0.009, 0.437, 0.405, 0.37, ...
        0.357, 0.314, 0.263, 0.204, 0.163, 0.13, 0.103, 0.079, ...
        0.057, 0.037, 0.018, 0.009, 0.431, 0.399, 0.365, 0.352, ...
        0.309, 0.259, 0.201, 0.16, 0.128, 0.101, 0.077, 0.056, ...
        0.036, 0.018, 0.009, 0.426, 0.394, 0.36, 0.347, 0.305, ...
        0.255, 0.197, 0.157, 0.126, 0.009, 0.076, 0.055, 0.035, ...
        0.017, 0.009, 0.42, 0.389, 0.355, 0.343, 0.301, 0.251, ...
        0.194, 0.154, 0.124, 0.098, 0.075, 0.054, 0.035, 0.017, ...
        0.009];
    q20 = [NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
        NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
        NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
        NA, NA, NA, NA, NA, 0.996, 0.992, 0.987, 0.983, 0.967, ...
        0.935, 0.871, 0.807, 0.743, 0.676, 0.606, 0.529, 0.44, ...
        0.321, 0.235, 0.95, 0.929, 0.901, 0.89, 0.845, 0.782, ...
        0.694, 0.623, 0.56, 0.5, 0.44, 0.377, 0.306, 0.218, 0.155, ...
        0.865, 0.836, 0.8, 0.786, 0.736, 0.67, 0.585, 0.52, 0.463, ...
        0.411, 0.358, 0.305, 0.245, 0.172, 0.126, 0.814, 0.778, ...
        0.732, 0.716, 0.661, 0.596, 0.516, 0.454, 0.402, 0.355, ...
        0.306, 0.261, 0.208, 0.144, 0.099, 0.746, 0.71, 0.67, ...
        0.657, 0.607, 0.545, 0.468, 0.41, 0.361, 0.317, 0.274, ...
        0.23, 0.184, 0.125, 0.085, 0.7, 0.667, 0.627, 0.614, ...
        0.565, 0.505, 0.432, 0.378, 0.331, 0.288, 0.25, 0.208, ...
        0.166, 0.114, 0.077, 0.664, 0.632, 0.592, 0.579, 0.531, ...
        0.474, 0.404, 0.354, 0.307, 0.268, 0.231, 0.192, 0.153, ...
        0.104, 0.07, 0.627, 0.603, 0.564, 0.551, 0.504, 0.449, ...
        0.381, 0.334, 0.29, 0.253, 0.217, 0.181, 0.143, 0.097, ...
        0.065, 0.612, 0.579, 0.54, 0.527, 0.481, 0.429, 0.362, ...
        0.216, 0.274, 0.239, 0.205, 0.172, 0.136, 0.091, 0.06, ...
        0.59, 0.557, 0.52, 0.506, 0.461, 0.411, 0.345, 0.301, ...
        0.261, 0.227, 0.195, 0.164, 0.129, 0.086, 0.057, 0.571, ...
        0.538, 0.502, 0.489, 0.445, 0.395, 0.332, 0.288, 0.25, ...
        0.217, 0.187, 0.157, 0.123, 0.082, 0.054, 0.554, 0.522, ...
        0.486, 0.473, 0.43, 0.382, 0.32, 0.277, 0.241, 0.209, ...
        0.179, 0.15, 0.118, 0.079, 0.052, 0.539, 0.508, 0.472, ...
        0.46, 0.418, 0.37, 0.31, 0.268, 0.233, 0.202, 0.173, ...
        0.144, 0.113, 0.076, 0.05, 0.526, 0.495, 0.46, 0.447, ...
        0.406, 0.359, 0.301, 0.26, 0.226, 0.195, 0.167, 0.139, ...
        0.109, 0.074, 0.049, 0.514, 0.484, 0.449, 0.437, 0.397, ...
        0.35, 0.293, 0.252, 0.219, 0.189, 0.162, 0.134, 0.105, ...
        0.071, 0.048, 0.503, 0.473, 0.439, 0.427, 0.387, 0.341, ...
        0.286, 0.246, 0.213, 0.184, 0.157, 0.13, 0.101, 0.069, ...
        0.047, 0.494, 0.464, 0.43, 0.418, 0.378, 0.333, 0.279, ...
        0.24, 0.208, 0.179, 0.152, 0.126, 0.098, 0.067, 0.046, ...
        0.485, 0.455, 0.422, 0.41, 0.371, 0.326, 0.273, 0.235, ...
        0.203, 0.175, 0.148, 0.123, 0.096, 0.065, 0.045, 0.477, ...
        0.447, 0.414, 0.402, 0.364, 0.32, 0.267, 0.23, 0.199, ...
        0.171, 0.145, 0.12, 0.094, 0.064, 0.044, 0.469, 0.44, ...
        0.407, 0.395, 0.358, 0.314, 0.262, 0.225, 0.195, 0.167, ...
        0.142, 0.117, 0.092, 0.062, 0.043, 0.462, 0.434, 0.401, ...
        0.39, 0.352, 0.309, 0.258, 0.221, 0.192, 0.164, 0.139, ...
        0.114, 0.09, 0.061, 0.042, 0.456, 0.428, 0.395, 0.383, ...
        0.346, 0.304, 0.254, 0.217, 0.189, 0.161, 0.136, 0.112, ...
        0.089, 0.06, 0.041, 0.45, 0.422, 0.39, 0.379, 0.342, ...
        0.3, 0.25, 0.214, 0.186, 0.158, 0.134, 0.11, 0.087, 0.059, ...
        0.041, 0.444, 0.417, 0.385, 0.374, 0.338, 0.296, 0.246, ...
        0.211, 0.183, 0.156, 0.132, 0.109, 0.086, 0.058, 0.04, ...
        0.439, 0.412, 0.381, 0.37, 0.333, 0.292, 0.243, 0.208, ...
        0.18, 0.154, 0.13, 0.107, 0.085, 0.058, 0.04, 0.434, ...
        0.407, 0.376, 0.365, 0.329, 0.288, 0.239, 0.205, 0.177, ...
        0.151, 0.128, 0.106, 0.083, 0.057, 0.039, 0.428, 0.402, ...
        0.372, 0.361, 0.326, 0.285, 0.236, 0.202, 0.175, 0.149, ...
        0.126, 0.104, 0.082, 0.056, 0.039];
    q21 = [NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
        NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
        NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
        NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
        NA, NA, NA, NA, NA, NA, 0.998, 0.995, 0.99, 0.987, 0.976, ...
        0.952, 0.902, 0.82, 0.795, 0.735, 0.669, 0.594, 0.504, ...
        0.374, 0.273, 0.97, 0.951, 0.924, 0.913, 0.872, 0.821, ...
        0.745, 0.68, 0.621, 0.563, 0.504, 0.439, 0.364, 0.268, ...
        0.195, 0.919, 0.885, 0.842, 0.828, 0.78, 0.725, 0.637, ...
        0.575, 0.517, 0.462, 0.408, 350, 0.285, 0.198, 0.138, ...
        0.868, 0.829, 0.78, 0.763, 0.71, 0.65, 0.57, 0.509, 0.454, ...
        0.402, 0.352, 0.298, 0.24, 0.166, 0.117, 0.816, 0.776, ...
        0.725, 0.71, 0.657, 0.594, 0.516, 0.458, 0.407, 0.36, ...
        0.313, 0.265, 0.212, 0.146, 0.103, 0.76, 0.726, 0.678, ...
        0.664, 0.612, 0.551, 0.474, 0.42, 0.374, 0.329, 0.286, ...
        0.24, 0.189, 0.13, 0.089, 0.713, 0.679, 0.638, 0.625, ...
        0.576, 0.517, 0.442, 0.391, 0.348, 0.305, 0.265, 0.221, ...
        0.173, 0.118, 0.08, 0.675, 0.642, 0.605, 0.592, 0.546, ...
        0.49, 0.419, 0.37, 0.326, 0.285, 0.247, 0.206, 0.161, ...
        0.11, 0.074, 0.649, 0.615, 0.578, 0.565, 0.521, 0.467, ...
        0.399, 0.351, 0.308, 0.269, 0.232, 0.194, 0.152, 0.104, ...
        0.07, 0.627, 0.593, 0.556, 0.544, 0.501, 0.448, 0.381, ...
        0.334, 0.293, 0.256, 0.219, 0.184, 0.144, 0.099, 0.066, ...
        0.607, 0.574, 0.537, 0.525, 0.483, 0.431, 0.366, 0.319, ...
        0.28, 0.245, 0.208, 0.175, 0.138, 0.094, 0.062, 0.58, ...
        0.557, 0.521, 0.509, 0.467, 0.416, 0.353, 0.307, 0.269, ...
        0.235, 0.199, 0.167, 0.132, 0.09, 0.059, 0.573, 0.542, ...
        0.507, 0.495, 0.453, 0.403, 0.341, 0.296, 0.259, 0.225, ...
        0.192, 0.161, 0.127, 0.086, 0.057, 0.559, 0.529, 0.494, ...
        0.482, 0.44, 0.391, 0.331, 0.287, 0.25, 0.218, 0.186, ...
        0.155, 0.122, 0.082, 0.054, 0.547, 0.517, 0.482, 0.469, ...
        0.428, 0.38, 0.322, 0.279, 0.243, 0.211, 0.18, 0.15, ...
        0.117, 0.078, 0.052, 0.536, 0.506, 0.472, 0.46, 0.419, ...
        0.371, 0.314, 0.271, 0.236, 0.205, 0.174, 0.145, 0.113, ...
        0.075, 0.05, 0.526, 0.496, 0.462, 0.45, 0.41, 0.363, ...
        0.306, 0.264, 0.229, 0.199, 0.17, 0.141, 0.11, 0.073, ...
        0.049, 0.517, 0.487, 0.453, 0.441, 0.402, 0.356, 0.299, ...
        0.258, 0.223, 0.194, 0.165, 0.137, 0.107, 0.071, 0.048, ...
        0.509, 0.479, 0.445, 0.434, 0.395, 0.349, 0.293, 0.252, ...
        0.218, 0.189, 0.161, 0.133, 0.105, 0.069, 0.046, 0.501, ...
        0.471, 0.438, 0.427, 0.388, 0.343, 0.287, 0.247, 0.214, ...
        0.185, 0.158, 0.13, 0.103, 0.068, 0.045, 0.493, 0.464, ...
        0.431, 0.42, 0.382, 0.337, 0.282, 0.242, 0.21, 0.181, ...
        0.154, 0.127, 0.1, 0.067, 0.043, 0.486, 0.457, 0.424, ...
        0.414, 0.376, 0.331, 0.277, 0.238, 0.206, 0.178, 0.151, ...
        0.125, 0.098, 0.066, 0.042, 0.479, 0.45, 0.418, 0.407, ...
        0.37, 0.325, 0.273, 0.234, 0.203, 0.175, 0.149, 0.123, ...
        0.096, 0.064, 0.041, 0.472, 0.444, 0.412, 0.402, 0.365, ...
        0.32, 0.269, 0.23, 0.2, 0.172, 0.146, 0.121, 0.094, 0.063, ...
        0.041, 0.466, 0.438, 0.406, 0.396, 0.36, 0.316, 0.265, ...
        0.227, 0.197, 0.17, 0.144, 0.119, 0.092, 0.062, 0.04, ...
        0.46, 0.433, 0.401, 0.391, 0.355, 0.312, 0.261, 0.224, ...
        0.194, 0.167, 0.142, 0.117, 0.091, 0.061, 0.04];
    q22 = [NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
        NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
        NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
        NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
        NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
        NA, NA, NA, NA, NA, NA, NA, 0.998, 0.995, 0.992, 0.99, ...
        0.983, 0.965, 0.93, 0.88, 830, 0.78, 0.72, 0.64, 0.54, ...
        0.41, 0.3, 0.97, 0.945, 0.919, 0.909, 0.881, 0.85, 0.78, ...
        0.73, 0.67, 0.61, 0.54, 0.47, 0.39, 0.27, 0.2, 0.922, ...
        0.89, 0.857, 0.846, 0.803, 0.745, 0.664, 0.602, 0.546, ...
        0.49, 0.434, 0.375, 0.309, 0.218, 0.156, 0.873, 0.84, ...
        0.8, 0.787, 0.737, 0.676, 0.592, 0.53, 0.478, 0.425, ...
        0.373, 0.32, 0.261, 0.186, 0.128, 0.826, 0.791, 0.749, ...
        0.734, 0.682, 0.62, 0.543, 0.483, 0.433, 0.384, 0.335, ...
        0.285, 0.231, 0.15, 0.111, 0.781, 0.745, 0.703, 0.688, ...
        0.637, 0.578, 0.503, 0.446, 0.397, 0.351, 0.305, 0.258, ...
        0.208, 0.142, 0.099, 0.74, 0.704, 0.661, 0.648, 0.6, ...
        0.543, 0.47, 0.416, 0.37, 0.325, 0.282, 0.238, 0.19, ...
        0.13, 0.09, 0.705, 0.67, 0.628, 0.616, 0.57, 0.515, 0.443, ...
        0.391, 0.347, 0.304, 0.263, 0.222, 0.177, 0.122, 0.084, ...
        0.674, 0.641, 0.602, 0.59, 0.546, 0.492, 0.421, 0.37, ...
        0.328, 0.287, 0.247, 0.208, 0.166, 0.115, 0.079, 0.647, ...
        0.616, 0.579, 0.568, 0.525, 0.472, 0.402, 0.353, 0.312, ...
        0.273, 0.234, 0.196, 0.156, 0.109, 0.075, 0.624, 0.595, ...
        0.559, 0.548, 0.507, 0.454, 0.386, 0.338, 0.298, 0.261, ...
        0.223, 0.186, 0.148, 0.104, 0.071, 0.605, 0.577, 0.542, ...
        0.531, 0.49, 0.438, 0.373, 0.325, 0.286, 0.25, 0.214, ...
        0.178, 0.142, 0.099, 0.067, 0.589, 0.561, 0.527, 0.516, ...
        0.475, 0.424, 0.361, 0.314, 0.276, 0.241, 0.206, 0.171, ...
        0.135, 0.094, 0.063, 0.575, 0.547, 0.514, 0.503, 0.462, ...
        0.412, 0.35, 0.304, 0.268, 0.233, 0.199, 0.165, 0.103, ...
        0.09, 0.06, 0.562, 0.535, 0.502, 0.491, 0.45, 0.401, ...
        0.34, 0.295, 0.26, 0.226, 0.193, 0.16, 0.125, 0.086, ...
        0.057, 0.551, 0.524, 0.491, 0.48, 0.44, 0.391, 0.331, ...
        0.287, 0.252, 0.22, 0.187, 0.155, 0.12, 0.082, 0.054, ...
        0.541, 0.514, 0.481, 0.47, 0.43, 0.382, 0.323, 0.28, ...
        0.245, 0.213, 0.182, 0.15, 0.116, 0.078, 0.051, 0.532, ...
        0.505, 0.472, 0.461, 0.421, 0.374, 0.316, 0.274, 0.239, ...
        0.207, 0.177, 0.146, 0.113, 0.075, 0.049, 0.524, 0.497, ...
        0.464, 0.452, 0.413, 0.367, 0.31, 0.268, 0.232, 0.201, ...
        0.172, 0.142, 0.111, 0.074, 0.047, 0.516, 0.489, 0.457, ...
        0.445, 0.406, 0.36, 0.304, 0.262, 0.227, 0.196, 0.168, ...
        0.138, 0.108, 0.073, 0.045, 0.508, 0.482, 0.45, 0.438, ...
        0.399, 0.354, 0.298, 0.257, 0.222, 0.192, 0.164, 0.135, ...
        0.106, 0.072, 0.044, 0.501, 0.475, 0.443, 0.432, 0.393, ...
        0.348, 0.292, 0.252, 0.218, 0.189, 0.161, 0.132, 0.104, ...
        0.071, 0.043, 0.495, 0.469, 0.437, 0.426, 0.387, 0.342, ...
        0.287, 0.247, 0.215, 0.186, 0.158, 0.13, 0.102, 0.069, ...
        0.042, 0.489, 0.463, 0.431, 0.419, 0.381, 0.337, 0.282, ...
        0.243, 0.211, 0.183, 0.155, 0.128, 0.1, 0.068, 0.041, ...
        0.483, 0.457, 0.425, 0.414, 0.376, 0.332, 0.278, 0.239, ...
        0.208, 0.18, 0.153, 0.126, 0.098, 0.067, 0.041];

	q10 = reshape(q10,15,30);
	q11 = reshape(q11,15,30);
	q12 = reshape(q12,15,30);
	q20 = reshape(q20,15,30);
	q21 = reshape(q21,15,30);
	q22 = reshape(q22,15,30);

	if (type == 10) 
        	q0 = q10(:,n)';
	elseif (type == 11) 
		q0 = q11(:,n)';
	elseif (type == 12) 
		q0 = q12(:,n)';
	elseif (type == 20) 
		q0 = q20(:,n)';
	elseif (type == 21) 
		q0 = q21(:,n)';
    	else q0 = q22(:,n)';
	end

	if (rev) 
        	q = qtable(p, q0, pp);
	else
		q = qtable(p, pp, q0);
    	end

	q(q<0)=0;
	q(q>1)=1;
end

