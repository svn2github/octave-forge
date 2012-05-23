<?php
/*************************************************************************************
 * octave.php
 * -----------
 * Author: Juan Pablo Carbajal (carbajal@ifi.uzh.ch)
 * Copyright: (c) 2012 Juan Pablo Carbajal (http://www.florian-knorn.com)
 * Release Version: 1.0.0
 * Date Started: 2012/05/22
 *
 * Octave M-file language file for GeSHi.
 * Derived from matlab.php by Florian Knorn and octave.lang for GtkSourceView.
 *
 * CHANGES
 * -------
 * 2012/05/22 (1.0.0)
 *   -  First Release
 *
 * TODO
 * -------------------------
 * Instead of keywords use groups for different type of highlight
 * http://qbnz.com/highlighter/geshi-doc.html#language-files
 *
 *************************************************************************************
 *
 *     This file is part of GeSHi.
 *
 *   GeSHi is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   GeSHi is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with GeSHi; if not, write to the Free Software
 *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 ************************************************************************************/

$language_data = array (
    'LANG_NAME' => 'GNU/Octave',
    'COMMENT_SINGLE' => array(1=> '#', 2 => '%'),
    'COMMENT_MULTI' => array('#{' => '#}', '%{' => '%}'),
    //Octave Strings
    'COMMENT_REGEXP' => array(
        2 => "/(?<![\\w\\)\\]\\}\\.])('[^\\n']*?')/"
    ),
    'CASE_KEYWORDS' => GESHI_CAPS_NO_CHANGE,
    'QUOTEMARKS' => array('"',"'"),
    'ESCAPE_CHAR' => '',
    'KEYWORDS' => array(
        // Data types
        1 => array(
        'cell', 'char', 'double', 'uint8', 'uint16', 'uint32', 'uint64',
        'int8','int16', 'int32', 'int64', 'logical', 'single', 'struct'
        ),
        // Storage type
        2 => array(
        'global', 'persistent', 'static'
        ),
        // Internal variables
        3 => array('ans'),
        // Reserved words
        4 => array(
        'break', 'case', 'catch', 'continue', 'do', 'else', 'elseif', 'end',
        'end_try_catch', 'end_unwind_protect', 'endfor', 'endfunction',
        'endif', 'endparfor', 'endswitch', 'endwhile', 'for', 'function',
        'if', 'otherwise', 'parfor', 'return',
        'switch', 'try', 'until', 'unwind_protect',
        'unwind_protect_cleanup', 'varargin', 'varargout', 'while'
        ),
        // Built in
        5 => array(
        'Inf', 'NaN', 'P_tmpdir', 'abs', 'acos', 'acosh',
        'add_input_event_hook', 'addlistener', 'addpath', 'addproperty',
        'all', 'allow_noninteger_range_as_index', 'and', 'angle', 'any',
        'arg', 'argnames', 'argv', 'asin', 'asinh', 'assignin', 'atan',
        'atan2', 'atanh', 'atexit', 'autoload', 'available_graphics_toolkits',
        'beep_on_error', 'bitand', 'bitmax', 'bitor', 'bitshift', 'bitxor',
        'builtin', 'canonicalize_file_name', 'cat', 'cbrt', 'cd', 'ceil',
        'cell2struct', 'cellstr', 'chdir', 'class', 'clc',
        'clear', 'columns', 'command_line_path', 'completion_append_char',
        'completion_matches', 'complex', 'confirm_recursive_rmdir', 'conj',
        'cos', 'cosh', 'cputime', 'crash_dumps_octave_core', 'ctranspose',
        'cumprod', 'cumsum', 'dbclear', 'dbcont', 'dbdown', 'dbnext',
        'dbquit', 'dbstack', 'dbstatus', 'dbstep', 'dbstop', 'dbtype', 'dbup',
        'dbwhere', 'debug_on_error', 'debug_on_interrupt', 'debug_on_warning',
        'default_save_options', 'dellistener', 'diag', 'diary', 'diff',
        'disp', 'do_braindead_shortcircuit_evaluation', 'do_string_escapes',
        'doc_cache_file', 'drawnow', 'dup2', 'e', 'echo',
        'echo_executing_commands', 'edit_history', 'eps', 'eq', 'erf', 'erfc',
        'erfcx', 'erfinv', 'errno', 'errno_list', 'error', 'eval', 'evalin',
        'exec', 'exist', 'exit', 'exp', 'expm1', 'eye', 'fclear',
        'fclose', 'fcntl', 'fdisp', 'feof', 'ferror', 'feval', 'fflush',
        'fgetl', 'fgets', 'fieldnames', 'file_in_loadpath', 'file_in_path',
        'filemarker', 'filesep', 'find_dir_in_path', 'finite', 'fix',
        'fixed_point_format', 'floor', 'fmod', 'fnmatch', 'fopen', 'fork',
        'format', 'formula', 'fprintf', 'fputs', 'fread', 'freport',
        'frewind', 'fscanf', 'fseek', 'fskipl', 'ftell', 'full', 'func2str',
        'functions', 'fwrite', 'gamma', 'gammaln', 'ge', 'genpath', 'get',
        'get_help_text', 'get_help_text_from_file', 'getegid', 'getenv',
        'geteuid', 'getgid', 'gethostname', 'getpgrp', 'getpid', 'getppid',
        'getuid', 'glob', 'gt', 'history', 'history_control', 'history_file',
        'history_size', 'history_timestamp_format_string', 'home', 'horzcat',
        'hypot', 'i', 'ifelse', 'ignore_function_time_stamp', 'imag',
        'inferiorto', 'info_file', 'info_program', 'inline', 'input',
        'intmax', 'intmin', 'ipermute',
        'is_absolute_filename', 'is_dq_string', 'is_function_handle',
        'is_rooted_relative_filename', 'is_sq_string', 'isalnum', 'isalpha',
        'isargout', 'isascii', 'isbool', 'iscell', 'iscellstr', 'ischar',
        'iscntrl', 'iscomplex', 'isdebugmode', 'isdigit', 'isempty',
        'isfield', 'isfinite', 'isfloat', 'isglobal', 'isgraph', 'ishandle',
        'isieee', 'isindex', 'isinf', 'isinteger', 'iskeyword', 'islogical',
        'islower', 'ismatrix', 'ismethod', 'isna', 'isnan', 'isnull',
        'isnumeric', 'isobject', 'isprint', 'ispunct', 'isreal', 'issorted',
        'isspace', 'issparse', 'isstruct', 'isupper', 'isvarname', 'isxdigit',
        'j', 'kbhit', 'keyboard', 'kill', 'lasterr', 'lasterror', 'lastwarn',
        'ldivide', 'le', 'length', 'lgamma', 'link', 'linspace',
        'list_in_columns', 'load', 'loaded_graphics_toolkits', 'log', 'log10',
        'log1p', 'log2', 'lower', 'lstat', 'lt',
        'make_absolute_filename', 'makeinfo_program', 'max_recursion_depth',
        'merge', 'methods', 'mfilename', 'minus', 'mislocked',
        'missing_function_hook', 'mkdir', 'mkfifo', 'mkstemp', 'mldivide',
        'mlock', 'mod', 'more', 'mpower', 'mrdivide', 'mtimes', 'munlock',
        'nargin', 'nargout', 'native_float_format', 'ndims', 'ne',
        'nfields', 'nnz', 'norm', 'not', 'nth_element', 'numel', 'nzmax',
        'octave_config_info', 'octave_core_file_limit',
        'octave_core_file_name', 'octave_core_file_options',
        'octave_tmp_file_name', 'onCleanup', 'ones',
        'optimize_subsasgn_calls', 'or', 'output_max_field_width',
        'output_precision', 'page_output_immediately', 'page_screen_output',
        'path', 'pathsep', 'pause', 'pclose', 'permute', 'pi', 'pipe', 'plus',
        'popen', 'popen2', 'power', 'print_empty_dimensions',
        'print_struct_array_contents', 'printf', 'prod',
        'program_invocation_name', 'program_name', 'putenv', 'puts', 'pwd',
        'quit', 'rats', 'rdivide', 're_read_readline_init_file',
        'read_readline_init_file', 'readdir', 'readlink', 'real', 'realmax',
        'realmin', 'register_graphics_toolkit', 'rehash', 'rem',
        'remove_input_event_hook', 'rename', 'repelems', 'reset', 'reshape',
        'resize', 'restoredefaultpath', 'rethrow', 'rmdir', 'rmfield',
        'rmpath', 'round', 'roundb', 'rows', 'run_history', 'save',
        'save_header_format_string', 'save_precision', 'saving_history',
        'scanf', 'set', 'setenv', 'sighup_dumps_octave_core', 'sign',
        'sigterm_dumps_octave_core', 'silent_functions', 'sin',
        'sinh', 'size', 'size_equal', 'sizemax', 'sizeof', 'sleep', 'sort',
        'source', 'spalloc', 'sparse', 'sparse_auto_mutate',
        'split_long_rows', 'sprintf', 'sqrt', 'squeeze', 'sscanf', 'stat',
        'stderr', 'stdin', 'stdout', 'str2func', 'strcmp', 'strcmpi',
        'string_fill_char', 'strncmp', 'strncmpi', 'struct2cell',
        'struct_levels_to_print', 'strvcat', 'subsasgn', 'subsref', 'sum',
        'sumsq', 'superiorto', 'suppress_verbose_help_message', 'symlink',
        'system', 'tan', 'tanh', 'terminal_size', 'tic', 'tilde_expand',
        'times', 'tmpfile', 'tmpnam', 'toascii', 'toc', 'tolower', 'toupper',
        'transpose', 'typeinfo',
        'umask', 'uminus', 'uname', 'undo_string_escapes', 'unlink',
        'uplus', 'upper', 'usage', 'usleep', 'vec', 'vectorize', 'vertcat',
        'waitfor', 'waitpid', 'warning', 'warranty', 'who', 'whos',
        'whos_line_format', 'yes_or_no', 'zeros'
        ),
        // Octave functions
        6 => array(
        'accumarray', 'accumdim', 'acosd', 'acot', 'acotd', 'acoth', 'acsc',
        'acscd', 'acsch', 'addpref', 'addtodate', 'allchild', 'amd',
        'ancestor', 'anova', 'arch_fit', 'arch_rnd', 'arch_test',
        'area', 'arma_rnd', 'asctime', 'asec', 'asecd', 'asech', 'asind',
        'assert', 'atand', 'autocor', 'autocov', 'autoreg_matrix', 'autumn',
        'axes', 'axis', 'balance', 'bar', 'barh', 'bartlett', 'bartlett_test',
        'base2dec', 'beep', 'bessel', 'besselj', 'beta', 'betacdf', 'betai',
        'betainc', 'betainv', 'betaln', 'betapdf', 'betarnd', 'bicg',
        'bicgstab', 'bicubic', 'bin2dec', 'bincoeff', 'binocdf', 'binoinv',
        'binopdf', 'binornd', 'bitcmp', 'bitget', 'bitset', 'blackman',
        'blanks', 'blkdiag', 'bone', 'box', 'brighten', 'bsxfun',
        'bug_report', 'bunzip2', 'bzip2', 'calendar', 'cart2pol', 'cart2sph',
        'cast', 'cauchy_cdf', 'cauchy_inv', 'cauchy_pdf', 'cauchy_rnd',
        'caxis', 'ccolamd', 'cell2mat', 'celldisp', 'cellfun', 'cellidx',
        'center', 'cgs', 'chi2cdf', 'chi2inv', 'chi2pdf', 'chi2rnd',
        'chisquare_test_homogeneity', 'chisquare_test_independence', 'chol',
        'chop', 'circshift', 'cla', 'clabel', 'clf', 'clg', 'clock',
        'cloglog', 'close', 'closereq', 'colamd', 'colloc', 'colon',
        'colorbar', 'colormap', 'colperm', 'colstyle', 'comet', 'comet3',
        'comma', 'common_size', 'commutation_matrix', 'compan',
        'compare_versions', 'compass', 'computer', 'cond', 'condest',
        'contour', 'contour3', 'contourc', 'contourf', 'contrast', 'conv',
        'conv2', 'convhull', 'convhulln', 'cool', 'copper', 'copyfile', 'cor',
        'cor_test', 'corr', 'corrcoef', 'cosd', 'cot', 'cotd', 'coth', 'cov',
        'cplxpair', 'cquad', 'cross', 'csc', 'cscd', 'csch', 'cstrcat',
        'csvread', 'csvwrite', 'ctime', 'cumtrapz', 'curl', 'cut', 'cylinder',
        'daspect', 'daspk', 'dasrt', 'dassl', 'date', 'datenum', 'datestr',
        'datetick', 'datevec', 'dblquad', 'deal', 'deblank', 'debug',
        'dec2base', 'dec2bin', 'dec2hex', 'deconv', 'del2', 'delaunay',
        'delaunay3', 'delaunayn', 'delete', 'demo', 'det', 'detrend',
        'diffpara', 'diffuse', 'dir', 'discrete_cdf', 'discrete_inv',
        'discrete_pdf', 'discrete_rnd', 'dispatch', 'display', 'divergence',
        'dlmread', 'dlmwrite', 'dmperm', 'doc', 'dos', 'dot', 'dsearch',
        'dsearchn', 'dump_prefs', 'duplication_matrix', 'durbinlevinson',
        'edit', 'eig', 'eigs', 'ellipsoid', 'empirical_cdf', 'empirical_inv',
        'empirical_pdf', 'empirical_rnd', 'eomday', 'error_text', 'errorbar',
        'etime', 'etreeplot', 'example', 'expcdf', 'expinv', 'expm', 'exppdf',
        'exprnd', 'ezcontour', 'ezcontourf', 'ezmesh', 'ezmeshc', 'ezplot',
        'ezplot3', 'ezpolar', 'ezsurf', 'ezsurfc', 'f_test_regression',
        'fact', 'factor', 'factorial', 'fail', 'fcdf', 'feather', 'fft',
        'fft2', 'fftconv', 'fftfilt', 'fftn', 'fftshift', 'fftw', 'figure',
        'fileattrib', 'fileparts', 'fileread', 'fill', 'filter', 'filter2',
        'find', 'findall', 'findobj', 'findstr', 'finv', 'flag', 'flipdim',
        'fliplr', 'flipud', 'fminbnd', 'fminunc', 'fpdf', 'fplot',
        'fractdiff', 'freqz', 'freqz_plot', 'frnd', 'fsolve', 'fstat',
        'fullfile', 'fzero', 'gamcdf', 'gaminv', 'gammai', 'gammainc',
        'gampdf', 'gamrnd', 'gca', 'gcbf', 'gcbo', 'gcd', 'gcf',
        'gen_doc_cache', 'genvarname', 'geocdf', 'geoinv', 'geopdf', 'geornd',
        'get_first_help_sentence', 'getappdata', 'getfield', 'getgrent',
        'getpref', 'getpwent', 'getrusage', 'ginput', 'givens', 'glpk',
        'glpkmex', 'gls', 'gmap40', 'gmres', 'gnuplot_binary', 'gplot',
        'gradient', 'graphics_toolkit', 'gray', 'gray2ind', 'grid',
        'griddata', 'griddata3', 'griddatan', 'gtext', 'guidata',
        'guihandles', 'gunzip', 'gzip', 'hadamard', 'hamming', 'hankel',
        'hanning', 'help', 'hess', 'hex2dec', 'hex2num', 'hggroup', 'hidden',
        'hilb', 'hist', 'histc', 'hold', 'hot', 'hotelling_test',
        'hotelling_test_2', 'housh', 'hsv', 'hsv2rgb', 'hurst', 'hygecdf',
        'hygeinv', 'hygepdf', 'hygernd', 'idivide', 'ifftshift', 'image',
        'imagesc', 'imfinfo', 'imread', 'imshow', 'imwrite', 'ind2gray',
        'ind2rgb', 'index', 'info', 'inpolygon', 'inputname', 'int2str',
        'interp1', 'interp1q', 'interp2', 'interp3', 'interpft', 'interpn',
        'intersect', 'intwarning', 'inv', 'invhilb', 'iqr',
        'is_duplicate_entry', 'is_global', 'is_leap_year', 'is_valid_file_id',
        'isa', 'isappdata', 'iscolumn', 'isdefinite', 'isdeployed', 'isdir',
        'isequal', 'isequalwithequalnans', 'isfigure', 'ishermitian',
        'ishghandle', 'ishold', 'isletter', 'ismac', 'ismember', 'isocolors',
        'isonormals', 'isosurface', 'ispc', 'ispref', 'isprime', 'isprop',
        'isrow', 'isscalar', 'issquare', 'isstr', 'isstrprop', 'issymmetric',
        'isunix', 'isvector', 'jet', 'kendall', 'kolmogorov_smirnov_cdf',
        'kolmogorov_smirnov_test', 'kolmogorov_smirnov_test_2', 'kron',
        'kruskal_wallis_test', 'krylov', 'krylovb', 'kurtosis', 'laplace_cdf',
        'laplace_inv', 'laplace_pdf', 'laplace_rnd', 'lcm', 'legend',
        'legendre', 'license', 'lin2mu', 'line', 'linkprop', 'list_primes',
        'loadaudio', 'loadobj', 'logistic_cdf', 'logistic_inv',
        'logistic_pdf', 'logistic_regression', 'logistic_rnd', 'logit',
        'loglog', 'loglogerr', 'logm', 'logncdf', 'logninv', 'lognpdf',
        'lognrnd', 'logspace', 'lookfor', 'lookup', 'ls', 'ls_command',
        'lsode', 'lsqnonneg', 'lu', 'luinc', 'magic', 'mahalanobis', 'manova',
        'mat2str', 'matlabroot', 'matrix_type', 'max', 'mcnemar_test',
        'md5sum', 'mean', 'meansq', 'median', 'menu', 'mesh', 'meshc',
        'meshgrid', 'meshz', 'mex', 'mexext', 'mgorth', 'mkoctfile', 'mkpp',
        'mode', 'moment', 'movefile', 'mpoles', 'mu2lin', 'namelengthmax',
        'nargchk', 'narginchk', 'nargoutchk', 'nbincdf', 'nbininv', 'nbinpdf',
        'nbinrnd', 'nchoosek', 'ndgrid', 'newplot', 'news', 'nextpow2',
        'nonzeros', 'normcdf', 'normest', 'norminv', 'normpdf', 'normrnd',
        'now', 'nproc', 'nthargout', 'nthroot', 'ntsc2rgb', 'null', 'num2str',
        'ocean', 'ols', 'onenormest', 'optimget', 'optimset', 'orderfields',
        'orient', 'orth', 'pack', 'paren', 'pareto', 'parseparams', 'pascal',
        'patch', 'pathdef', 'pbaspect', 'pcg', 'pchip', 'pcolor', 'pcr',
        'peaks', 'periodogram', 'perl', 'perms', 'perror', 'pie', 'pie3',
        'pink', 'pinv', 'pkg', 'planerot', 'playaudio', 'plot', 'plot3',
        'plotmatrix', 'plotyy', 'poisscdf', 'poissinv', 'poisspdf',
        'poissrnd', 'pol2cart', 'polar', 'poly', 'polyaffine', 'polyarea',
        'polyder', 'polyderiv', 'polyfit', 'polygcd', 'polyint', 'polyout',
        'polyreduce', 'polyval', 'polyvalm', 'postpad', 'pow2', 'powerset',
        'ppder', 'ppint', 'ppjumps', 'ppplot', 'ppval', 'pqpnonneg',
        'prctile', 'prepad', 'primes', 'print', 'printAllBuiltins',
        'print_usage', 'prism', 'probit', 'profexplore', 'profile',
        'profshow', 'prop_test_2', 'python', 'qp', 'qqplot', 'qr', 'quad',
        'quadcc', 'quadgk', 'quadl', 'quadv', 'quantile', 'quiver', 'quiver3',
        'qz', 'qzhess', 'rainbow', 'rand', 'randi', 'range', 'rank', 'ranks',
        'rat', 'rcond', 'reallog', 'realpow', 'realsqrt', 'record',
        'rectangle', 'rectint', 'recycle', 'refresh', 'refreshdata', 'regexp',
        'regexptranslate', 'replot', 'repmat', 'residue', 'rgb2hsv',
        'rgb2ind', 'rgb2ntsc', 'ribbon', 'rindex', 'rmappdata', 'rmpref',
        'roots', 'rose', 'rosser', 'rot90', 'rotdim', 'rref', 'run',
        'run_count', 'run_test', 'rundemos', 'runlength', 'runtests',
        'saveas', 'saveaudio', 'saveimage', 'saveobj', 'savepath', 'scatter',
        'scatter3', 'schur', 'sec', 'secd', 'sech', 'semicolon', 'semilogx',
        'semilogxerr', 'semilogy', 'semilogyerr', 'setappdata', 'setaudio',
        'setdiff', 'setfield', 'setpref', 'setstr', 'setxor', 'shading',
        'shell_cmd', 'shg', 'shift', 'shiftdim', 'sign_test', 'sinc', 'sind',
        'sinetone', 'sinewave', 'skewness', 'slice', 'sombrero', 'sortrows',
        'spaugment', 'spconvert', 'spdiags', 'spearman', 'spectral_adf',
        'spectral_xdf', 'specular', 'speed', 'spencer', 'speye', 'spfun',
        'sph2cart', 'sphere', 'spinmap', 'spline', 'spones', 'spparms',
        'sprand', 'sprandn', 'sprandsym', 'spring', 'spstats', 'spy', 'sqp',
        'sqrtm', 'stairs', 'statistics', 'std', 'stdnormal_cdf',
        'stdnormal_inv', 'stdnormal_pdf', 'stdnormal_rnd', 'stem', 'stem3',
        'stft', 'str2double', 'str2num', 'strcat', 'strchr', 'strerror',
        'strfind', 'strjust', 'strmatch', 'strread', 'strsplit', 'strtok',
        'strtrim', 'strtrunc', 'structfun', 'studentize', 'sub2ind',
        'subplot', 'subsindex', 'subspace', 'substr', 'substruct', 'summer',
        'surf', 'surface', 'surfc', 'surfl', 'surfnorm', 'svd', 'svds',
        'swapbytes', 'syl', 'sylvester_matrix', 'symbfact', 'symrcm',
        'symvar', 'synthesis', 't_test', 't_test_2', 't_test_regression',
        'table', 'tand', 'tar', 'tcdf', 'tempdir', 'tempname', 'test', 'text',
        'textread', 'textscan', 'time', 'tinv', 'title', 'toeplitz', 'tpdf',
        'trace', 'trapz', 'treelayout', 'treeplot', 'tril', 'trimesh',
        'triplequad', 'triplot', 'trisurf', 'trnd', 'tsearch', 'tsearchn',
        'type', 'typecast', 'u_test', 'uicontextmenu', 'uicontrol',
        'uigetdir', 'uigetfile', 'uimenu', 'uipanel', 'uipushtool',
        'uiputfile', 'uiresume', 'uitoggletool', 'uitoolbar', 'uiwait',
        'unidcdf', 'unidinv', 'unidpdf', 'unidrnd', 'unifcdf', 'unifinv',
        'unifpdf', 'unifrnd', 'unimplemented', 'union', 'unique', 'unix',
        'unmkpp', 'unpack', 'untabify', 'untar', 'unwrap', 'unzip',
        'urlwrite', 'usejava', 'validatestring', 'values', 'vander', 'var',
        'var_test', 'vech', 'ver', 'version', 'view', 'voronoi', 'voronoin',
        'waitbar', 'waitforbuttonpress', 'warning_ids', 'wavread', 'wavwrite',
        'wblcdf', 'wblinv', 'wblpdf', 'wblrnd', 'weekday', 'weibcdf',
        'weibinv', 'weibpdf', 'weibrnd', 'welch_test', 'what', 'which',
        'white', 'whitebg', 'wienrnd', 'wilcoxon_test', 'wilkinson', 'winter',
        'xlabel', 'xlim', 'xor', 'ylabel', 'ylim', 'yulewalker', 'z_test',
        'z_test_2', 'zip', 'zlabel', 'zlim', 'zscore', 'airy', 'arrayfun',
        'besselh', 'besseli', 'besselk', 'bessely', 'bitpack', 'bitunpack',
        'blkmm', 'cellindexmat', 'cellslices', 'chol2inv', 'choldelete',
        'cholinsert', 'cholinv', 'cholshift', 'cholupdate', 'convn',
        'csymamd', 'cummax', 'cummin', 'daspk_options', 'dasrt_options',
        'dassl_options', 'endgrent', 'endpwent', 'etree', 'getgrgid',
        'getgrnam', 'getpwnam', 'getpwuid', 'gmtime', 'gui_mode', 'ifft',
        'ifft2', 'ifftn', 'ind2sub', 'inverse', 'localtime', 'lsode_options',
        'luupdate', 'mat2cell', 'min', 'mktime', 'mouse_wheel_zoom',
        'num2cell', 'num2hex', 'qrdelete', 'qrinsert', 'qrshift', 'qrupdate',
        'quad_options', 'rande', 'randg', 'randn', 'randp', 'randperm',
        'regexpi', 'regexprep', 'rsf2csf', 'setgrent', 'setpwent', 'sprank',
        'strftime', 'strptime', 'strrep', 'svd_driver', 'symamd', 'triu',
        'urlread'
        ),
        // Private builtin
        7 => array(
        '__accumarray_max__', '__accumarray_min__', '__accumarray_sum__',
        '__accumdim_sum__', '__builtins__', '__calc_dimensions__',
        '__current_scope__', '__display_tokens__', '__dump_symtab_info__',
        '__end__', '__get__', '__go_axes__', '__go_axes_init__',
        '__go_delete__', '__go_execute_callback__', '__go_figure__',
        '__go_figure_handles__', '__go_handles__', '__go_hggroup__',
        '__go_image__', '__go_line__', '__go_patch__', '__go_surface__',
        '__go_text__', '__go_uicontextmenu__', '__go_uicontrol__',
        '__go_uimenu__', '__go_uipanel__', '__go_uipushtool__',
        '__go_uitoggletool__', '__go_uitoolbar__', '__gud_mode__',
        '__image_pixel_size__', '__is_handle_visible__', '__isa_parent__',
        '__keywords__', '__lexer_debug_flag__', '__list_functions__',
        '__operators__', '__parent_classes__', '__parser_debug_flag__',
        '__pathorig__', '__profiler_data__', '__profiler_enable__',
        '__profiler_reset__', '__request_drawnow__', '__sort_rows_idx__',
        '__token_count__', '__varval__', '__version_info__', '__which__'
        ),
        // Private Octave functions
        8 => array(
        '__all_opts__', '__contourc__', '__delaunayn__', '__dispatch__',
        '__dsearchn__', '__error_text__', '__finish__', '__fltk_uigetfile__',
        '__glpk__', '__gnuplot_drawnow__', '__init_fltk__',
        '__init_gnuplot__', '__lin_interpn__', '__magick_read__',
        '__makeinfo__', '__pchip_deriv__', '__plt_get_axis_arg__', '__qp__',
        '__voronoi__', '__fltk_maxtime__', '__fltk_redraw__', '__ftp__',
        '__ftp_ascii__', '__ftp_binary__', '__ftp_close__', '__ftp_cwd__',
        '__ftp_delete__', '__ftp_dir__', '__ftp_mget__', '__ftp_mkdir__',
        '__ftp_mode__', '__ftp_mput__', '__ftp_pwd__', '__ftp_rename__',
        '__ftp_rmdir__', '__magick_finfo__', '__magick_format_list__',
        '__magick_write__'
        ),
        // Builtin Global Variables
        9 => array(
        'EDITOR', 'EXEC_PATH', 'F_DUPFD', 'F_GETFD', 'F_GETFL', 'F_SETFD',
        'F_SETFL', 'I', 'IMAGE_PATH', 'J', 'NA', 'OCTAVE_HOME',
        'OCTAVE_VERSION', 'O_APPEND', 'O_ASYNC', 'O_CREAT', 'O_EXCL',
        'O_NONBLOCK', 'O_RDONLY', 'O_RDWR', 'O_SYNC', 'O_TRUNC', 'O_WRONLY',
        'PAGER', 'PAGER_FLAGS', 'PS1', 'PS2', 'PS4', 'SEEK_CUR', 'SEEK_END',
        'SEEK_SET', 'SIG', 'S_ISBLK', 'S_ISCHR', 'S_ISDIR', 'S_ISFIFO',
        'S_ISLNK', 'S_ISREG', 'S_ISSOCK', 'WCONTINUE', 'WCOREDUMP',
        'WEXITSTATUS', 'WIFCONTINUED', 'WIFEXITED', 'WIFSIGNALED',
        'WIFSTOPPED', 'WNOHANG', 'WSTOPSIG', 'WTERMSIG', 'WUNTRACED'
        ),
        // Floating point number
        13 => array("\b([0-9]+[Ee][-]?[0-9]+|([0-9]*\.[0-9]+|[0-9]+\.)([Ee][-]?[0-9]+)?)[fFlL]?"
        ),
        // Octal number
        14 => array("\b0[0-7]+([Uu]([Ll]|LL|ll)?|([Ll]|LL|ll)[Uu]?)?\b"),
        // Hex number
        15 => array("\b0[xX][0-9a-fA-F]+([Uu]([Ll]|LL|ll)?|([Ll]|LL|ll)[Uu]?)?\b"),
        // Reserved constants
        // Most of the constants can be used as functions too. Do not highlight
        // as constants if followed by parentheses.
        16 => array("[e|eps|(J|j|I|i)|(Inf|inf)|(NaN|nan)|NA|ones|pi|rand|randn|zeros])(\b(?!(\s)*\()"),
        // Package manager
        17 => array("(\b)pkg(?!(\s)*\()(\s)+(((un)?install|(un)?load|list|(global|local)_list|describe|prefix|(re)?build)(\b))?")
    ),
    'SYMBOLS' => array(
        0 => array(
            '!', '!=', '&', '&&','|', '||', '~', '~=',
            '<', '<=', '=', '==', '>', '>='),
        1 => array('*', '**', '+', '++', '-', '--', '/', '&#92;'),
        2 => array('.*', '.**','./', '.^', '^','.&#92;'),
        3 => array(':'),
        4 => array(',', '...', ';')
     ),
    'CASE_SENSITIVE' => array(
        GESHI_COMMENTS => false,
        1 => false,
        2 => false,
        3 => false,
        4 => false,
        5 => false,
        6 => false,
        7 => false,
        8 => false,
        9 => false,
        13 => false,
        14 => false,
        15 => false,
        16 => false,
        17 => false
    ),
    'URLS' => array(
        1 => '',
        2 => '',
        3 => '',
        4 => '',
        5 => '',
        6 => '',
        7 => '',
        8 => '',
        9 => '',
        13 => '',
        14 => '',
        15 => '',
        16 => '',
        17 => ''
    ),
    'OOLANG' => true,
    'OBJECT_SPLITTERS' => array(
        1 => '.',
        2 => '::'
    ),
    'REGEXPS' => array(
        //Complex numbers
//        0 => "(?<![\\w\\/])[+-]?[\\d]*([\\d]\\.|\\.[\\d])?[\\d]*[ij](?![\\w]|\<DOT>html)",
        // Boolean
        // false and true can be used as functions too.
        // Do not highlight as boolean if followed by parentheses.
//        1 => "(\b([false|true])(\\b(?!(\\s)*\())"
        //Function handle
        1 => array(
            GESHI_SEARCH => '(@([A-Za-z_][A-Za-z1-9_]*)?)',
            GESHI_REPLACE => '\\1',
            GESHI_MODIFIERS => '',
            GESHI_BEFORE => '',
            GESHI_AFTER => ''
            )//,
        // Decimal TODO not working
//        2 => array(
//            GESHI_SEARCH => '(\b([1-9][0-9]*|0)([Uu]([Ll]|LL|ll)?|([Ll]|LL|ll)[Uu]?)?\b)',
//            GESHI_REPLACE => '\\1',
//            GESHI_MODIFIERS => '',
//            GESHI_BEFORE => '',
//            GESHI_AFTER => ''
//            )

    ),
    'STRICT_MODE_APPLIES' => GESHI_NEVER,
    'SCRIPT_DELIMITERS' => array(),
    'HIGHLIGHT_STRICT_BLOCK' => array(),
    'STYLES' => array(
        'KEYWORDS' => array(
        1 => 'color: #2E8B57; font-weight:bold;', // Data types
        2 => 'color: #2E8B57;', // Storage type
        3 => 'color: #0000FF; font-weight:bold;', // Internal variable
        4 => 'color: #990000; font-weight:bold;', // Reserved words
        5 => 'color: #008A8C; font-weight:bold;', // Built-in
        6 => 'color: #008A8C;', // Octave functions
        9 => 'color: #000000; font-weight:bold;' // Builtin Global Variables
        ),
        'COMMENTS' => array(
        1 => 'color: #0000FF; font-style: italic;',
        2 => 'color: #0000FF; font-style: italic;',
        'MULTI' => 'color: #0000FF; font-style: italic;'
        ),
        'ESCAPE_CHAR' => array(
        0 => ''
        ),
        'BRACKETS' => array(
        0 => 'color: #080;'
        ),
        'STRINGS' => array(
        //0 => 'color: #A020F0;'
        ),
        'NUMBERS' => array(
        0 => 'color: #33f;'
        ),
        'METHODS' => array(
        1 => '',
        2 => ''
        ),
        'SYMBOLS' => array(
        0 => 'color: #FF0000; font-weight:bold;',
        1 => 'color: #FF0000; font-weight:bold;',
        2 => 'color: #FF0000; font-weight:bold;',
        3 => 'color: #FF0000;',
        4 => 'color: #33f'
        ),
        'REGEXPS' => array(
        0 => 'color: #33f;',
        1 => 'color: #0000FF; font-weight:bold;', //Function handle
        2 => 'color: #CC3399;' //Decimal
        ),
        'SCRIPT' => array(
        0 => ''
        )
    )
);
?>
