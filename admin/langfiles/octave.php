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
           'cell', 'char ', 'double ', 'uint8', 'uint16', 'uint32', 'uint64',
           'int8','int16', 'int32', 'int64', 'logical ', 'single ', 'struct '
          ),
          // Storage type
          2 => array(
            'global ', 'persistent ', 'static '
           ),
          // Internal variables
          3 => array(
            'ans'
           ),
          // Reserved words
          4 => array(
                  'break', 'case', 'catch', 'continue', 'do', 'else',
                  'elseif','end_try_catch', 'end_unwind_protect', 'endfor',
                  'endfunction', 'endif', 'endswitch', 'endwhile', 'for',
                  'function', 'if','otherwise', 'return', 'switch ', 'try',
                  'until', 'unwind_protect', 'unwind_protect_cleanup', 'varargin',
                  'varargout', 'while'
          ),
          // Built in
          5 => array(
          'all','any','exist','is','logical','mislocked',
          'abs','acos','acosh','acot','acoth','acsc','acsch','airy','angle',
          'area','asec','asech','asin','asinh','atan','atan2','atanh',
          'auread','autumn','auwrite','axes','axis','balance','bar','bar3',
          'bar3h','barh','besselh','besseli','besselj','besselk','Bessely',
          'beta','betainc','betaln','bicg','bicgstab','bin2dec','bitand',
          'bitcmp','bitget','bitmax','bitor','bitset','bitshift','bitxor',
          'blkdiag','bone','box','brighten','builtin','bwcontr','calendar',
          'camdolly','camlight','camlookat','camorbit','campan','campos',
          'camproj','camroll','camtarget','camup','camva','camzoom','capture',
          'cart2pol','cart2sph','cat','caxis','cdf2rdf','ceil',
          'cell2struct','celldisp','cellfun','cellplot','cellstr','cgs',
          'char','chol','cholinc','cholupdate','cla','clabel','class','clc',
          'clf','clg','clock','close','colmmd','colorbar','colorcube',
          'colordef','colormap','colperm','comet','comet3','compan','compass',
          'complex','computer','cond','condeig','condest','coneplot','conj',
          'contour','contourc','contourf','contourslice','contrast','conv',
          'conv2','convhull','cool','copper','copyobj','corrcoef','cos',
          'cosh','cot','coth','cov','cplxpair','cputime','cross','csc','csch',
          'cumprod','cumsum','cumtrapz','cylinder','daspect','date','datenum',
          'datestr','datetick','datevec','dbclear','dbcont','dbdown',
          'dblquad','dbmex','dbquit','dbstack','dbstatus','dbstep','dbstop',
          'dbtype','dbup','deblank','dec2bin','dec2hex','deconv','del2',
          'delaunay','det','diag','dialog','diff','diffuse','dlmread',
          'dlmwrite','dmperm','double','dragrect','drawnow','dsearch','eig',
          'eigs','ellipj','ellipke','eomday','eps','erf','erfc','erfcx',
          'erfiny','error','errorbar','errordlg','etime','eval','evalc',
          'evalin','exp','expint','expm','eye','ezcontour','ezcontourf',
          'ezmesh','ezmeshc','ezplot','ezplot3','ezpolar','ezsurf','ezsurfc',
          'factor','factorial','fclose','feather','feof','ferror','feval',
          'fft','fft2','fftshift','fgetl','fgets','fieldnames','figure',
          'fill','fill3','filter','filter2','find','findfigs','findobj',
          'findstr','fix','flag','flipdim','fliplr','flipud','floor','flops',
          'fmin','fmins','fopen','fplot','fprintf','fread','frewind','fscanf',
          'fseek','ftell','full','funm','fwrite','fzero','gallery','gamma',
          'gammainc','gammaln','gca','gcbo','gcd','gcf','gco','get',
          'getfield','ginput','gmres','gradient','gray','graymon','grid',
          'griddata','gsvd','gtext','hadamard','hankel','hdf','helpdlg',
          'hess','hex2dec','hex2num','hidden','hilb','hist','hold','hot',
          'hsv','hsv2rgb','i','ifft','ifft2','ifftn','ifftshift','imag',
          'image','imfinfo','imread','imwrite','ind2sub','Inf','inferiorto',
          'inline','inpolygon','input','inputdlg','inputname',
          'int2str','interp1','interp2','interp3','interpft',
          'interpn','intersect','inv','invhilb','ipermute','isa','ishandle',
          'ismember','isocaps','isonormals','isosurface','j','jet','keyboard',
          'lcm','legend','legendre','light','lighting','lightingangle',
          'lin2mu','line','lines','linspace','listdlg','loadobj','log',
          'log10','log2','loglog','logm','logspace','lower','lscov','lu',
          'luinc','magic','mat2str','material','max','mean','median','menu',
          'menuedit','mesh','meshc','meshgrid','min','mod','msgbox','mu2lin',
          'NaN','nargchk','nargin','nargout','nchoosek','ndgrid','ndims',
          'newplot','nextpow2','nnls','nnz','nonzeros','norm','normest','now',
          'null','num2cell','num2str','nzmax','ode113,','ode15s,','ode23s,',
          'ode23t,','ode23tb','ode45,','odefile','odeget','odeset','ones',
          'orient','orth','pagedlg','pareto','pascal','patch','pause',
          'pbaspect','pcg','pcolor','peaks','perms','permute','pi','pie',
          'pie3','pinv','plot','plot3','plotmatrix','plotyy','pol2cart',
          'polar','poly','polyarea','polyder','polyeig','polyfit','polyval',
          'polyvalm','pow2','primes','print','printdlg','printopt','prism',
          'prod','propedit','qmr','qr','qrdelete','qrinsert','qrupdate',
          'quad','questdlg','quiver','quiver3','qz','rand','randn','randperm',
          'rank','rat','rats','rbbox','rcond','real','realmax','realmin',
          'rectangle','reducepatch','reducevolume','refresh','rem','repmat',
          'reset','reshape','residue','rgb2hsv','rgbplot','ribbon','rmfield',
          'roots','rose','rot90','rotate','rotate3d','round','rref',
          'rrefmovie','rsf2csf','saveobj','scatter','scatter3','schur',
          'script','sec','sech','selectmoveresize','semilogx','semilogy',
          'set','setdiff','setfield','setxor','shading','shg','shiftdim',
          'shrinkfaces','sign','sin','single','sinh','slice','smooth3','sort',
          'sortrows','sound','soundsc','spalloc','sparse','spconvert',
          'spdiags','specular','speye','spfun','sph2cart','sphere','spinmap',
          'spline','spones','spparms','sprand','sprandn','sprandsym','spring',
          'sprintf','sqrt','sqrtm','squeeze','sscanf','stairs','std','stem',
          'stem3','str2double','str2num','strcat','strcmp','strcmpi',
          'stream2','stream3','streamline','strings','strjust','strmatch',
          'strncmp','strrep','strtok','struct','struct2cell','strvcat',
          'sub2ind','subplot','subspace','subvolume','sum','summer',
          'superiorto','surf','surf2patch','surface','surfc','surfl',
          'surfnorm','svd','svds','symmmd','symrcm','symvar','tan','tanh',
          'texlabel','text Create','textread','textwrap','tic','title','toc',
          'toeplitz','trace','trapz','tril','trimesh','trisurf','triu',
          'tsearch','uicontext Create','uicontextmenu','uicontrol',
          'uigetfile','uimenu','uiputfile','uiresume',
          'uisetcolor','uisetfont','uiwait Used','union','unique','unwrap',
          'upper','var','varargin','varargout','vectorize','view','viewmtx',
          'voronoi','waitbar','waitforbuttonpress','warndlg','warning',
          'waterfall','wavread','wavwrite','weekday','whitebg','wilkinson',
          'winter','wk1read','wk1write','xlabel','xlim','ylabel','ylim',
          'zeros','zlabel','zlim','zoom',
          'addpath','cd','clear','copyfile','delete','diary','dir','disp',
          'doc','docopt','echo','edit','fileparts','format','fullfile','help',
          'helpdesk','helpwin','home','inmem','lasterr','lastwarn','length',
          'load','lookfor','ls','matlabrc','matlabroot','mkdir','mlock',
          'more','munlock','open','openvar','pack','partialpath','path',
          'pathtool','profile','profreport','pwd','quit','rmpath','save',
          'saveas','size','tempdir','tempname','type','ver','version','web',
          'what','whatsnew','which','who','whos','workspace'
          ),
          // Octave functions Function __list_functions__ lists them all
          6 => array(
    '__all_opts__', '__contourc__', '__delaunayn__', '__dispatch__',
    '__dsearchn__', '__error_text__', '__finish__', '__fltk_uigetfile__',
    '__glpk__', '__gnuplot_drawnow__', '__init_fltk__', '__init_gnuplot__',
    '__lin_interpn__', '__magick_read__', '__makeinfo__', '__pchip_deriv__',
    '__plt_get_axis_arg__', '__qp__', '__voronoi__', 'accumarray', 'accumdim',
    'acosd', 'acot', 'acotd', 'acoth', 'acsc', 'acscd', 'acsch', 'addpref',
    'addtodate', 'allchild', 'amd', 'ancestor', 'anova', 'ans', 'arch_fit',
    'arch_rnd', 'arch_test', 'area', 'arma_rnd', 'asctime', 'asec', 'asecd',
    'asech', 'asind', 'assert', 'atand', 'autocor', 'autocov', 'autoreg_matrix',
    'autumn', 'axes', 'axis', 'balance', 'bar', 'barh', 'bartlett',
    'bartlett_test', 'base2dec', 'beep', 'bessel', 'besselj', 'beta', 'betacdf',
    'betai', 'betainc', 'betainv', 'betaln', 'betapdf', 'betarnd', 'bicg',
    'bicgstab', 'bicubic', 'bin2dec', 'bincoeff', 'binocdf', 'binoinv',
    'binopdf', 'binornd', 'bitcmp', 'bitget', 'bitset', 'blackman', 'blanks',
    'blkdiag', 'bone', 'box', 'brighten', 'bsxfun', 'bug_report', 'bunzip2',
    'bzip2', 'calendar', 'cart2pol', 'cart2sph', 'cast', 'cauchy_cdf',
    'cauchy_inv', 'cauchy_pdf', 'cauchy_rnd', 'caxis', 'ccolamd', 'cell2mat',
    'celldisp', 'cellfun', 'cellidx', 'center', 'cgs', 'chi2cdf', 'chi2inv',
    'chi2pdf', 'chi2rnd', 'chisquare_test_homogeneity',
    'chisquare_test_independence', 'chol', 'chop', 'circshift', 'cla', 'clabel',
    'clf', 'clg', 'clock', 'cloglog', 'close', 'closereq', 'colamd', 'colloc',
    'colon', 'colorbar', 'colormap', 'colperm', 'colstyle', 'comet', 'comet3',
    'comma', 'common_size', 'commutation_matrix', 'compan', 'compare_versions',
    'compass', 'computer', 'cond', 'condest', 'contour', 'contour3', 'contourc',
    'contourf', 'contrast', 'conv', 'conv2', 'convhull', 'convhulln', 'cool',
    'copper', 'copyfile', 'cor', 'cor_test', 'corr', 'corrcoef', 'cosd', 'cot',
    'cotd', 'coth', 'cov', 'cplxpair', 'cquad', 'cross', 'csc', 'cscd', 'csch',
    'cstrcat', 'csvread', 'csvwrite', 'ctime', 'cumtrapz', 'curl', 'cut',
    'cylinder', 'daspect', 'daspk', 'dasrt', 'dassl', 'date', 'datenum',
    'datestr', 'datetick', 'datevec', 'dblquad', 'deal', 'deblank', 'debug',
    'dec2base', 'dec2bin', 'dec2hex', 'deconv', 'del2', 'delaunay', 'delaunay3',
    'delaunayn', 'delete', 'demo', 'det', 'detrend', 'diffpara', 'diffuse',
    'dir', 'discrete_cdf', 'discrete_inv', 'discrete_pdf', 'discrete_rnd',
    'dispatch', 'display', 'divergence', 'dlmread', 'dlmwrite', 'dmperm', 'doc',
    'dos', 'dot', 'dsearch', 'dsearchn', 'dump_prefs', 'duplication_matrix',
    'durbinlevinson', 'edit', 'eig', 'eigs', 'ellipsoid', 'empirical_cdf',
    'empirical_inv', 'empirical_pdf', 'empirical_rnd', 'eomday', 'error_text',
    'errorbar', 'etime', 'etreeplot', 'example', 'expcdf', 'expinv', 'expm',
    'exppdf', 'exprnd', 'ezcontour', 'ezcontourf', 'ezmesh', 'ezmeshc',
    'ezplot', 'ezplot3', 'ezpolar', 'ezsurf', 'ezsurfc', 'f_test_regression',
    'fact', 'factor', 'factorial', 'fail', 'fcdf', 'feather', 'fft', 'fft2',
    'fftconv', 'fftfilt', 'fftn', 'fftshift', 'fftw', 'figure', 'fileattrib',
    'fileparts', 'fileread', 'fill', 'filter', 'filter2', 'find', 'findall',
    'findobj', 'findstr', 'finv', 'flag', 'flipdim', 'fliplr', 'flipud',
    'fminbnd', 'fminunc', 'fpdf', 'fplot', 'fractdiff', 'freqz', 'freqz_plot',
    'frnd', 'fsolve', 'fstat', 'fullfile', 'fzero', 'gamcdf', 'gaminv',
    'gammai', 'gammainc', 'gampdf', 'gamrnd', 'gca', 'gcbf', 'gcbo', 'gcd',
    'gcf', 'gen_doc_cache', 'genvarname', 'geocdf', 'geoinv', 'geopdf',
    'geornd', 'get_first_help_sentence', 'getappdata', 'getfield', 'getgrent',
    'getpref', 'getpwent', 'getrusage', 'ginput', 'givens', 'glpk', 'glpkmex',
    'gls', 'gmap40', 'gmres', 'gnuplot_binary', 'gplot', 'gradient',
    'graphics_toolkit', 'gray', 'gray2ind', 'grid', 'griddata', 'griddata3',
    'griddatan', 'gtext', 'guidata', 'guihandles', 'gunzip', 'gzip', 'hadamard',
    'hamming', 'hankel', 'hanning', 'help', 'hess', 'hex2dec', 'hex2num',
    'hggroup', 'hidden', 'hilb', 'hist', 'histc', 'hold', 'hot',
    'hotelling_test', 'hotelling_test_2', 'housh', 'hsv', 'hsv2rgb', 'hurst',
    'hygecdf', 'hygeinv', 'hygepdf', 'hygernd', 'idivide', 'ifftshift', 'image',
    'imagesc', 'imfinfo', 'imread', 'imshow', 'imwrite', 'ind2gray', 'ind2rgb',
    'index', 'info', 'inpolygon', 'inputname', 'int2str', 'interp1', 'interp1q',
    'interp2', 'interp3', 'interpft', 'interpn', 'intersect', 'intwarning',
    'inv', 'invhilb', 'iqr', 'is_duplicate_entry', 'is_global', 'is_leap_year',
    'is_valid_file_id', 'isa', 'isappdata', 'iscolumn', 'isdefinite',
    'isdeployed', 'isdir', 'isequal', 'isequalwithequalnans', 'isfigure',
    'ishermitian', 'ishghandle', 'ishold', 'isletter', 'ismac', 'ismember',
    'isocolors', 'isonormals', 'isosurface', 'ispc', 'ispref', 'isprime',
    'isprop', 'isrow', 'isscalar', 'issquare', 'isstr', 'isstrprop',
    'issymmetric', 'isunix', 'isvector', 'jet', 'kendall',
    'kolmogorov_smirnov_cdf', 'kolmogorov_smirnov_test',
    'kolmogorov_smirnov_test_2', 'kron', 'kruskal_wallis_test', 'krylov',
    'krylovb', 'kurtosis', 'laplace_cdf', 'laplace_inv', 'laplace_pdf',
    'laplace_rnd', 'lcm', 'legend', 'legendre', 'license', 'lin2mu', 'line',
    'linkprop', 'list_primes', 'loadaudio', 'loadobj', 'logistic_cdf',
    'logistic_inv', 'logistic_pdf', 'logistic_regression', 'logistic_rnd',
    'logit', 'loglog', 'loglogerr', 'logm', 'logncdf', 'logninv', 'lognpdf',
    'lognrnd', 'logspace', 'lookfor', 'lookup', 'ls', 'ls_command', 'lsode',
    'lsqnonneg', 'lu', 'luinc', 'magic', 'mahalanobis', 'manova', 'mat2str',
    'matlabroot', 'matrix_type', 'max', 'mcnemar_test', 'md5sum', 'mean',
    'meansq', 'median', 'menu', 'mesh', 'meshc', 'meshgrid', 'meshz', 'mex',
    'mexext', 'mgorth', 'mkoctfile', 'mkpp', 'mode', 'moment', 'movefile',
    'mpoles', 'mu2lin', 'namelengthmax', 'nargchk', 'narginchk', 'nargoutchk',
    'nbincdf', 'nbininv', 'nbinpdf', 'nbinrnd', 'nchoosek', 'ndgrid', 'newplot',
    'news', 'nextpow2', 'nonzeros', 'normcdf', 'normest', 'norminv', 'normpdf',
    'normrnd', 'now', 'nproc', 'nthargout', 'nthroot', 'ntsc2rgb', 'null',
    'num2str', 'ocean', 'ols', 'onenormest', 'optimget', 'optimset',
    'orderfields', 'orient', 'orth', 'pack', 'paren', 'pareto', 'parseparams',
    'pascal', 'patch', 'pathdef', 'pbaspect', 'pcg', 'pchip', 'pcolor', 'pcr',
    'peaks', 'periodogram', 'perl', 'perms', 'perror', 'pie', 'pie3', 'pink',
    'pinv', 'pkg', 'planerot', 'playaudio', 'plot', 'plot3', 'plotmatrix',
    'plotyy', 'poisscdf', 'poissinv', 'poisspdf', 'poissrnd', 'pol2cart',
    'polar', 'poly', 'polyaffine', 'polyarea', 'polyder', 'polyderiv',
    'polyfit', 'polygcd', 'polyint', 'polyout', 'polyreduce', 'polyval',
    'polyvalm', 'postpad', 'pow2', 'powerset', 'ppder', 'ppint', 'ppjumps',
    'ppplot', 'ppval', 'pqpnonneg', 'prctile', 'prepad', 'primes', 'print',
    'print_usage', 'prism', 'probit', 'profexplore', 'profile', 'profshow',
    'prop_test_2', 'python', 'qp', 'qqplot', 'qr', 'quad', 'quadcc', 'quadgk',
    'quadl', 'quadv', 'quantile', 'quiver', 'quiver3', 'qz', 'qzhess',
    'rainbow', 'rand', 'randi', 'range', 'rank', 'ranks', 'rat', 'rcond',
    'reallog', 'realpow', 'realsqrt', 'record', 'rectangle', 'rectint',
    'recycle', 'refresh', 'refreshdata', 'regexp', 'regexptranslate',
    'releasePKG', 'replot', 'repmat', 'residue', 'rgb2hsv', 'rgb2ind',
    'rgb2ntsc', 'ribbon', 'rindex', 'rmappdata', 'rmpref', 'roots', 'rose',
    'rosser', 'rot90', 'rotdim', 'rref', 'run', 'run_count', 'run_test',
    'rundemos', 'runlength', 'runtests', 'saveas', 'saveaudio', 'saveimage',
    'saveobj', 'savepath', 'scatter', 'scatter3', 'schur', 'sec', 'secd',
    'sech', 'semicolon', 'semilogx', 'semilogxerr', 'semilogy', 'semilogyerr',
    'setappdata', 'setaudio', 'setdiff', 'setfield', 'setpref', 'setstr',
    'setxor', 'shading', 'shell_cmd', 'shg', 'shift', 'shiftdim', 'sign_test',
    'sinc', 'sind', 'sinetone', 'sinewave', 'skewness', 'slice', 'sombrero',
    'sortrows', 'spaugment', 'spconvert', 'spdiags', 'spearman', 'spectral_adf',
    'spectral_xdf', 'specular', 'speed', 'spencer', 'speye', 'spfun',
    'sph2cart', 'sphere', 'spinmap', 'spline', 'spones', 'spparms', 'sprand',
    'sprandn', 'sprandsym', 'spring', 'spstats', 'spy', 'sqp', 'sqrtm',
    'stairs', 'statistics', 'std', 'stdnormal_cdf', 'stdnormal_inv',
    'stdnormal_pdf', 'stdnormal_rnd', 'stem', 'stem3', 'stft', 'str2double',
    'str2num', 'strcat', 'strchr', 'strerror', 'strfind', 'strjust', 'strmatch',
    'strread', 'strsplit', 'strtok', 'strtrim', 'strtrunc', 'structfun',
    'studentize', 'sub2ind', 'subplot', 'subsindex', 'subspace', 'substr',
    'substruct', 'summer', 'surf', 'surface', 'surfc', 'surfl', 'surfnorm',
    'svd', 'svds', 'swapbytes', 'syl', 'sylvester_matrix', 'symbfact', 'symrcm',
    'symvar', 'synthesis', 't_test', 't_test_2', 't_test_regression', 'table',
    'tand', 'tar', 'tcdf', 'tempdir', 'tempname', 'test', 'text', 'textread',
    'textscan', 'time', 'tinv', 'title', 'toeplitz', 'tpdf', 'trace', 'trapz',
    'treelayout', 'treeplot', 'tril', 'trimesh', 'triplequad', 'triplot',
    'trisurf', 'trnd', 'tsearch', 'tsearchn', 'type', 'typecast', 'u_test',
    'uicontextmenu', 'uicontrol', 'uigetdir', 'uigetfile', 'uimenu', 'uipanel',
    'uipushtool', 'uiputfile', 'uiresume', 'uitoggletool', 'uitoolbar',
    'uiwait', 'unidcdf', 'unidinv', 'unidpdf', 'unidrnd', 'unifcdf', 'unifinv',
    'unifpdf', 'unifrnd', 'unimplemented', 'union', 'unique', 'unix', 'unmkpp',
    'unpack', 'untabify', 'untar', 'unwrap', 'unzip', 'urlwrite', 'usejava',
    'validatestring', 'values', 'vander', 'var', 'var_test', 'vech', 'ver',
    'version', 'view', 'voronoi', 'voronoin', 'waitbar', 'waitforbuttonpress',
    'warning_ids', 'wavread', 'wavwrite', 'wblcdf', 'wblinv', 'wblpdf',
    'wblrnd', 'weekday', 'weibcdf', 'weibinv', 'weibpdf', 'weibrnd',
    'welch_test', 'what', 'which', 'white', 'whitebg', 'wienrnd',
    'wilcoxon_test', 'wilkinson', 'winter', 'xlabel', 'xlim', 'xor', 'ylabel',
    'ylim', 'yulewalker', 'z_test', 'z_test_2', 'zip', 'zlabel', 'zlim',
    'zscore', '__fltk_maxtime__', '__fltk_redraw__', '__ftp__', '__ftp_ascii__',
    '__ftp_binary__', '__ftp_close__', '__ftp_cwd__', '__ftp_delete__',
    '__ftp_dir__', '__ftp_mget__', '__ftp_mkdir__', '__ftp_mode__',
    '__ftp_mput__', '__ftp_pwd__', '__ftp_rename__', '__ftp_rmdir__',
    '__magick_finfo__', '__magick_format_list__', '__magick_write__', 'airy',
    'arrayfun', 'besselh', 'besseli', 'besselk', 'bessely', 'bitpack',
    'bitunpack', 'blkmm', 'cellindexmat', 'cellslices', 'chol2inv',
    'choldelete', 'cholinsert', 'cholinv', 'cholshift', 'cholupdate', 'convn',
    'csymamd', 'cummax', 'cummin', 'daspk_options', 'dasrt_options',
    'dassl_options', 'endgrent', 'endpwent', 'etree', 'getgrgid', 'getgrnam',
    'getpwnam', 'getpwuid', 'gmtime', 'gui_mode', 'ifft', 'ifft2', 'ifftn',
    'ind2sub', 'inverse', 'localtime', 'lsode_options', 'luupdate', 'mat2cell',
    'min', 'mktime', 'mouse_wheel_zoom', 'num2cell', 'num2hex', 'qrdelete',
    'qrinsert', 'qrshift', 'qrupdate', 'quad_options', 'rande', 'randg',
    'randn', 'randp', 'randperm', 'regexpi', 'regexprep', 'rsf2csf', 'setgrent',
    'setpwent', 'sprank', 'strftime', 'strptime', 'strrep', 'svd_driver',
    'symamd', 'triu', 'urlread'
          ),
          //Function handle
          7 => array("@([A-Za-z_][A-Za-z1-9_]*)?"),
          // Boolean
          // false and true can be used as functions too.
          // Do not highlight as boolean if followed by parentheses.
          8 => array("\b([false|true])(\b(?!(\s)*\()"),
          // Decimal
          9 => array("\b([1-9][0-9]*|0)([Uu]([Ll]|LL|ll)?|([Ll]|LL|ll)[Uu]?)?\b"),
          // Floating point number
          10 => array("\b([0-9]+[Ee][-]?[0-9]+|([0-9]*\.[0-9]+|[0-9]+\.)([Ee][-]?[0-9]+)?)[fFlL]?"
           ),
          // Octal number
          11 => array("\b0[0-7]+([Uu]([Ll]|LL|ll)?|([Ll]|LL|ll)[Uu]?)?\b"),
          // Hex number
          12 => array("\b0[xX][0-9a-fA-F]+([Uu]([Ll]|LL|ll)?|([Ll]|LL|ll)[Uu]?)?\b"),
          // Reserved constants
          // Most of the constants can be used as functions too. Do not highlight
          // as constants if followed by parentheses.
          13 => array("[e|eps|(J|j|I|i)|(Inf|inf)|(NaN|nan)|NA|ones|pi|rand|randn|zeros])(\b(?!(\s)*\()"),
          // Package manager
          14 => array("(\b)pkg(?!(\s)*\()(\s)+(((un)?install|(un)?load|list|(global|local)_list|describe|prefix|(re)?build)(\b))?")
    ),
    'SYMBOLS' => array("((\.)?\+{1,2}?(?!\+) | (\.)?\-{1,2}?(?!\-) |
                (\.)?\*{1,2}?(?!\*) | (\.)?\/(?!\^) |
                (\.)?\\(?!\^) | (\.)?\^(?!\^) |
                (?&lt;=[0-9a-zA-Z_)\]}])(\.)?' | &lt;=? |
                &gt;=? | != | ~= | == | &lt;&gt; |
                &amp;{1,2}?(?!&amp;) | \|{1,2}?(?!\|) | ! | ~ |
                = | : | ...)"
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
        10 => false,
        11 => false,
        12 => false,
        13 => false,
        14 => false
        ),
    'STYLES' => array(
        'KEYWORDS' => array(
            1 => 'color: #2E8B57; font-weight:bold;', // Data types
            2 => 'color: #2E8B57; font-weight:bold;', // Storage type
            3 => 'color: #0000FF; font-weight:bold;', // Internal variable
            4 => 'color: #990000; font-weight:bold;', // Reserved words
            5 => 'color: #008A8C; font-weight:bold;', // Built-in
            6 => 'color: #33CC33;' // Octave functions
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
            0 => 'color: #080;'
            ),
        'REGEXPS' => array(
            0 => 'color: #33f;'
            ),
        'SCRIPT' => array(
            0 => ''
            )
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
        10 => '',
        11 => '',
        12 => '',
        13 => '',
        14 => ''
        ),
    'OOLANG' => true,
    'OBJECT_SPLITTERS' => array(
        1 => '.',
        2 => '::'
        ),
    'REGEXPS' => array(
        //Complex numbers
        0 => '(?<![\\w\\/])[+-]?[\\d]*([\\d]\\.|\\.[\\d])?[\\d]*[ij](?![\\w]|\<DOT>html)'
        ),
    'STRICT_MODE_APPLIES' => GESHI_NEVER,
    'SCRIPT_DELIMITERS' => array(),
    'HIGHLIGHT_STRICT_BLOCK' => array()
);

?>
