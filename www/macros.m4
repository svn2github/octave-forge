define(`__BASE_ADDRESS__', `esyscmd(/bin/sh ./get-base-address)')dnl
define(`__TEXT_DIR__', `__BASE_ADDRESS__`text/'')dnl
define(`__IMAGE_DIR__', `__BASE_ADDRESS__`images/'')dnl
dnl
dnl
dnl
define(`__LINK__', `ifdef(`__TEXT_MODE__', `', `link="$1"')')dnl
define(`__VLINK__', `ifdef(`__TEXT_MODE__', `', `vlink="$1"')')dnl
define(`__ALINK__', `ifdef(`__TEXT_MODE__', `', `alink="$1"')')dnl
define(`__TEXT__', `ifdef(`__TEXT_MODE__', `', `text="$1"')')dnl
define(`__COLOR__', `ifdef(`__TEXT_MODE__', `', `color="$1"')')dnl
define(`__BGCOLOR__', `ifdef(`__TEXT_MODE__', `', `bgcolor="$1"')')dnl
dnl
define(`__FACE__', `ifdef(`__TEXT_MODE__', `', `face="$1"')')dnl
dnl
dnl
define(`__LINK_COLOR__', `#0050fa')dnl
define(`__VLINK_COLOR__', `#33ccff')dnl
define(`__ALINK_COLOR__', `#ff0000')dnl
define(`__TEXT_COLOR__', `#000000')dnl
define(`__BG_COLOR__', `#ffffff')dnl
dnl
define(`__TITLE_BAR_BG_COLOR__',   `#10a0ff')dnl
define(`__TITLE_BAR_FONT_COLOR__', `#ffffff')dnl
define(`__TITLE_BAR_FACE__', `Helvetica')dnl
dnl
ifdef(`__TEXT_MODE__',
      `define(`__RULE__', `<hr>')',
      `define(`__RULE__', `<hr noshade="noshade">')')dnl
dnl
define(`__DOWNLOAD_BG_COLOR__', `#d0e0ff')dnl
define(`__NAV_SELECTED_COLOR__', `#000000')dnl
define(`__NAV_BG_COLOR__', `#ffffff')dnl
dnl
define(`__NAV_FACE__', `Helvetica')dnl
dnl
dnl
dnl
define(`__DEFAULT_LINK_TEXT__', `ifelse($#, 2, `$1://$2', `$3')')dnl
define(`__HTTP__',
       ``<a href="http://$1">'__DEFAULT_LINK_TEXT__(`http', $*)`</a>'')dnl
define(`__MAILTO__',
       ``<a href="mailto:$1">'__DEFAULT_LINK_TEXT__(`http', $*)`</a>'')dnl
define(`__FTP__',
       ``<a href="ftp://$1">'__DEFAULT_LINK_TEXT__(`http', $*)`</a>'')dnl
dnl
define(`__OCTAVE_IMAGE__',
       ``<img src="'__IMAGE_DIR__`$1" alt="[$2]" ' ifelse($#, 3, `$3')`>'')dnl
dnl
define(`__OCTAVE_TEXT_HTTP__',
       ``<a href="'__TEXT_DIR__`$1">$2</a>'')dnl
dnl
define(`__OCTAVE_GRAPHICS_HTTP__',
       ``<a href="'__BASE_ADDRESS__`$1">$2</a>'')dnl
dnl
ifdef(`__TEXT_MODE__',
      `define(`__OCTAVE_HTTP__', `__OCTAVE_TEXT_HTTP__($1, $2)')',
      `define(`__OCTAVE_HTTP__', `__OCTAVE_GRAPHICS_HTTP__($1, $2)')')dnl
dnl
dnl
dnl
define(`__OCTAVE_FTP__',
       `__FTP__(ftp.octave.org/pub/octave/$1, $2)')dnl
dnl
dnl
dnl
define(`__OCTAVE_TEXT_MODE_GRAPHIC__',
       `__OCTAVE_GRAPHICS_HTTP__(images/$1, $2)')dnl
dnl
dnl
dnl
define(`__HEADER__', `<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<head>
<title>$1</title>
<link rel="stylesheet" type="text/css" href="__BASE_ADDRESS__/octave-forge.css" />
</head>
<body>
<div id="title"><h1>$1</h1></div>
<div id="nav">
 <a href="__BASE_ADDRESS__/index.html">Home</a>
 <a href="__BASE_ADDRESS__/packages.html">Packages</a>
 <a href="__BASE_ADDRESS__/developers.html">Developers</a>
 <a href="__BASE_ADDRESS__/docs.html">Docs</a>
 <a href="__BASE_ADDRESS__/FAQ.html">FAQ</a> 
 <a href="__BASE_ADDRESS__/bugs.html">Bugs</a> 
 <a href="__BASE_ADDRESS__/archive.html">Mailing Lists</a>
 <a href="__BASE_ADDRESS__/links.html">Links</a>
</div>

<div id="content">
')dnl
dnl
dnl
dnl
define(`__DOC_HEADER__', `<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<head>
<title>$1</title>
<link rel="stylesheet" type="text/css" href="__BASE_ADDRESS__/octave-forge.css" />
</head>
<body>
<div id="title"><h1>$1</h1></div>
<div id="nav">
include([[[doc/menu.include]]])
</div>
include([[[doc/alphabetic.include]]])
<div id="content">
')dnl
dnl
dnl
dnl
define(`__BIG_HEADER__', `__HEADER__($1)
<p>
ifdef(`__TEXT_MODE__',
  `<h1>__OCTAVE_TEXT_MODE_GRAPHIC__(`octave-logo.jpg', `Octave')</h1>
  <h2>__OCTAVE_TEXT_MODE_GRAPHIC__(`lorenz.jpg', `Lorenz Attractor')</h2>
  <hr>',
  `<table width="100%" border="0">
<tr><td align="left">
  __OCTAVE_IMAGE__(`octave-logo.jpg', `Octave')</td>
<td align="right">
  __OCTAVE_IMAGE__(`lorenz.jpg', `Lorenz Attractor')</td></tr>
<tr><td colspan="2">__RULE__</td></tr>
</table>')
</p>')dnl
dnl
dnl
dnl
define(`__nav_button__',
`ifelse(`$1', `$2',
  `<font color="__NAV_SELECTED_COLOR__">$4</font>',
  `__OCTAVE_HTTP__($3, $4)')')dnl
dnl
dnl
dnl
define(`__ext_nav_button__', `__HTTP__($1, $2)')dnl
dnl
dnl
dnl
define(`__view_button__',
`ifdef(`__TEXT_MODE__',
       `__OCTAVE_GRAPHICS_HTTP__(__FILE_NAME__, `Graphics View')',
       `__OCTAVE_TEXT_HTTP__(__FILE_NAME__, `Text View')')')dnl
dnl
dnl
dnl
define(`__NAVIGATION__', `<small>
<p>
ifdef(`__TEXT_MODE__', `<center>',
`<table width="100%" cellpadding="3" border="0">
<tr><td align="center" __BG_COLOR__(`__NAV_BG_COLOR__')>
<font __COLOR__(`__LINK_COLOR__')
      __FACE__(`__NAV_FACE__')>')
 [ __nav_button__($1, `home', `octave.html', `Home')
 | __nav_button__($1, `history', `history.html', `History')
 | __nav_button__($1, `news', `news.html', `News')
 | __nav_button__($1, `docs', `docs.html', `Docs')
 | __ext_nav_button__(`wiki.octave.org', `Wiki')
 | __nav_button__($1, `faq', `FAQ.html', `FAQ') 
 | __nav_button__($1, `help', `help.html', `Help') 
 | __nav_button__($1, `bugs', `bugs.html', `Bugs') 
 ]<br>
 [ __nav_button__($1, `license', `license.html', `License')
 | __nav_button__($1, `download', `download.html', `Download')
 | __nav_button__($1, `archive', `archive.html', `Mailing List Archive')
 | __nav_button__($1, `funding', `funding.html', `Funding')
 | __nav_button__($1, `help-wanted', `help-wanted.html', `Help Wanted') ]
ifdef(`__TEXT_MODE__', `</center>', `</font></td></tr></table>')
</p>')dnl
dnl
dnl
dnl
define(`__TRAILER__', `
</body>
</html>')dnl
dnl
dnl
dnl
define(`__OCTAVE_TRAILER__', `__NAVIGATION__(`$1')
__COPYING__
__TRAILER__')dnl
dnl
dnl
dnl
define(`__TITLE_BAR__', `<p>
ifdef(`__TEXT_MODE__',
`<h3>$1</h3>',
`<table width="100%" cellpadding="3" border="0">
<tr>
<td align="left" __BGCOLOR__(`__TITLE_BAR_BG_COLOR__')>
<font __COLOR__(`__TITLE_BAR_FONT_COLOR__')
      __FACE__(`__TITLE_BAR_FACE__')>
<big>
<b>
$1
</b>
</big>
</font>
</td>
</tr>
</table>')
</p>')dnl
dnl
dnl
dnl
define(`__TEXT_DOWNLOAD_INFO__', `<ul>
<li> __FTP__(`ftp.octave.org/pub/octave', `Stable') (also currently ancient and obsolete)
<ul>
<li>Version: $1
    (__OCTAVE_FTP__(`obsolete/octave-'$1`.tar.gz',`.tar.gz'))
    (__OCTAVE_FTP__(`obsolete/octave-'$1`.tar.bz2',`.tar.bz2'))
</li>
<li>Released: $2</li>
</li>
</ul>
<li>__FTP__(`ftp.octave.org/pub/octave', `Testing') (you probably want this)
<ul>
<li>Version: $3
    (__OCTAVE_FTP__(`octave-'$3`.tar.gz',`.tar.gz'))
    (__OCTAVE_FTP__(`octave-'$3`.tar.bz2',`.tar.bz2'))
</li>
<li>Released: $4</li>
</li>
<li>__FTP__(`ftp.octave.org/pub/octave/bleeding-edge', `Development') (latest features, but expect a few rough spots)
<ul>
<li>Version: $5
    (__OCTAVE_FTP__(`bleeding-edgeoctave-'$5`.tar.gz',`.tar.gz'))
    (__OCTAVE_FTP__(`bleeding-edge/octave-'$5`.tar.bz2',`.tar.bz2'))
</li>
<li>Released: $6</li>
</li>
</ul>
</li>
</ul>')
dnl
dnl
dnl
define(`__GRAPHICS_DOWNLOAD_INFO__',
`<table width="100%" cellpadding="3" border="0">
<tr><td><b>Octave version</b></td>
<td><b>Version</b></td>
<td><b>Release Date</b></td></tr>
<tr><td __BGCOLOR__(`__DOWNLOAD_BG_COLOR__')>
__FTP__(`ftp.octave.org/pub/octave', `Stable') (also currently ancient and obsolete)</td>
<td __BGCOLOR__(`__DOWNLOAD_BG_COLOR__')>$1
    (__OCTAVE_FTP__(`obsolete/octave-'$1`.tar.gz',`.tar.gz'))
    (__OCTAVE_FTP__(`obsolete/octave-'$1`.tar.bz2',`.tar.bz2'))
</td>
<td __BGCOLOR__(`__DOWNLOAD_BG_COLOR__')>$2</td></tr>
<tr><td __BGCOLOR__(`__DOWNLOAD_BG_COLOR__')>
__FTP__(`ftp.octave.org/pub/octave', `Testing') (you probably want this)</td>
<td __BGCOLOR__(`__DOWNLOAD_BG_COLOR__')>$3
    (__OCTAVE_FTP__(`octave-'$3`.tar.gz',`.tar.gz'))
    (__OCTAVE_FTP__(`octave-'$3`.tar.bz2',`.tar.bz2'))
</td>
<td __BGCOLOR__(`__DOWNLOAD_BG_COLOR__')>$4</td></tr>
<tr><td __BGCOLOR__(`__DOWNLOAD_BG_COLOR__')>
__FTP__(`ftp.octave.org/pub/octave/bleeding-edge', `Development')  (latest features, but expect a few rough spots)</td>
<td __BGCOLOR__(`__DOWNLOAD_BG_COLOR__')>$5
    (__OCTAVE_FTP__(`bleeding-edge/octave-'$5`.tar.gz',`.tar.gz'))
    (__OCTAVE_FTP__(`bleeding-edge/octave-'$5`.tar.bz2',`.tar.bz2'))
</td>
<td __BGCOLOR__(`__DOWNLOAD_BG_COLOR__')>$6</td></tr>
</table>')dnl
dnl
dnl
dnl
define(`__DOWNLOAD_INFO__', `<p>
ifdef(`__TEXT_MODE__',
`__TEXT_DOWNLOAD_INFO__($@)',
`__GRAPHICS_DOWNLOAD_INFO__($@)')
</p>
')dnl
dnl
dnl
dnl
changequote([[[, ]]])
