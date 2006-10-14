m4_define(`__GROUP_ID__',`group_id=2888')m4_dnl
m4_define(`__SOURCEFORGE__',`http://sourceforge.net')m4_dnl
m4_dnl m4_define(`__PACKAGE__',`http://prdownloads.sourceforge.net/octave')m4_dnl
m4_define(`__PACKAGE__',`http://octave.dbateman.org/packages')m4_dnl
m4_define(`__SUMMARY__',`__SOURCEFORGE__/projects/octave/')m4_dnl
m4_define(`__FORUMS__',`__SOURCEFORGE__/forum/?__GROUP_ID__')m4_dnl
m4_define(`__CVS__',`__SOURCEFORGE__/cvs/?__GROUP_ID__')m4_dnl
m4_define(`__DOWNLOAD__',`__SOURCEFORGE__/project/showfiles.php?__GROUP_ID__')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__BASE_ADDRESS__', `m4_esyscmd(/bin/sh ./get-base-address)')m4_dnl
m4_define(`__TEXT_DIR__', `__BASE_ADDRESS__`text/'')m4_dnl
m4_define(`__IMAGE_DIR__', `__BASE_ADDRESS__`images/'')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__LINK__', `m4_ifdef(`__TEXT_MODE__', `', `link="$1"')')m4_dnl
m4_define(`__VLINK__', `m4_ifdef(`__TEXT_MODE__', `', `vlink="$1"')')m4_dnl
m4_define(`__ALINK__', `m4_ifdef(`__TEXT_MODE__', `', `alink="$1"')')m4_dnl
m4_define(`__TEXT__', `m4_ifdef(`__TEXT_MODE__', `', `text="$1"')')m4_dnl
m4_define(`__COLOR__', `m4_ifdef(`__TEXT_MODE__', `', `color="$1"')')m4_dnl
m4_define(`__BGCOLOR__', `m4_ifdef(`__TEXT_MODE__', `', `bgcolor="$1"')')m4_dnl
m4_dnl
m4_define(`__FACE__', `m4_ifdef(`__TEXT_MODE__', `', `face="$1"')')m4_dnl
m4_dnl
m4_dnl
m4_define(`__LINK_COLOR__', `#0050fa')m4_dnl
m4_define(`__VLINK_COLOR__', `#33ccff')m4_dnl
m4_define(`__ALINK_COLOR__', `#ff0000')m4_dnl
m4_define(`__TEXT_COLOR__', `#000000')m4_dnl
m4_define(`__BG_COLOR__', `#ffffff')m4_dnl
m4_dnl
m4_define(`__TITLE_BAR_BG_COLOR__',   `#10a0ff')m4_dnl
m4_define(`__TITLE_BAR_FONT_COLOR__', `#ffffff')m4_dnl
m4_define(`__TITLE_BAR_FACE__', `Helvetica')m4_dnl
m4_dnl
m4_ifdef(`__TEXT_MODE__',
      `m4_define(`__RULE__', `<hr>')',
      `m4_define(`__RULE__', `<hr noshade="noshade">')')m4_dnl
m4_dnl
m4_define(`__DOWNLOAD_BG_COLOR__', `#d0e0ff')m4_dnl
m4_define(`__NAV_SELECTED_COLOR__', `#000000')m4_dnl
m4_define(`__NAV_BG_COLOR__', `#ffffff')m4_dnl
m4_dnl
m4_define(`__NAV_FACE__', `Helvetica')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__DEFAULT_LINK_TEXT__', `ifelse($#, 2, `$1://$2', `$3')')m4_dnl
m4_define(`__HTTP__',
       ``<a href="http://$1">'__DEFAULT_LINK_TEXT__(`http', $*)`</a>'')m4_dnl
m4_define(`__MAILTO__',
       ``<a href="mailto:$1">'__DEFAULT_LINK_TEXT__(`http', $*)`</a>'')m4_dnl
m4_define(`__FTP__',
       ``<a href="ftp://$1">'__DEFAULT_LINK_TEXT__(`http', $*)`</a>'')m4_dnl
m4_dnl
m4_define(`__OCTAVE_IMAGE__',
       ``<img src="'__IMAGE_DIR__`$1" alt="[$2]" ' ifelse($#, 3, `$3')`>'')m4_dnl
m4_dnl
m4_define(`__OCTAVE_TEXT_HTTP__',
       ``<a href="'__TEXT_DIR__`$1">$2</a>'')m4_dnl
m4_dnl
m4_define(`__OCTAVE_GRAPHICS_HTTP__',
       ``<a href="'__BASE_ADDRESS__`$1">$2</a>'')m4_dnl
m4_dnl
m4_ifdef(`__TEXT_MODE__',
      `m4_define(`__OCTAVE_HTTP__', `__OCTAVE_TEXT_HTTP__($1, $2)')',
      `m4_define(`__OCTAVE_HTTP__', `__OCTAVE_GRAPHICS_HTTP__($1, $2)')')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__OCTAVE_FTP__',
       `__FTP__(ftp.octave.org/pub/octave/$1, $2)')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__OCTAVE_TEXT_MODE_GRAPHIC__',
       `__OCTAVE_GRAPHICS_HTTP__(images/$1, $2)')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__HTML_HEADER__', `<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<title>$1</title>
<link rel="stylesheet" type="text/css" href="__BASE_ADDRESS__/octave-forge.css" />
<script type="text/javascript">
<!--
function goto_url(url) {
  if (url != "-1") {
    location.href=url;
  }
}
function unfold(id) {
    document.getElementById(id).style.display = "none;";
    document.getElementById(id+"_detailed").style.display = "block;";
}
function fold(id) {
    document.getElementById(id+"_detailed").style.display = "none;";
    document.getElementById(id).style.display = "block;";
}
// -->
</script>
</head>
<body>
<div id="title"><h1>$1</h1></div>
')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__MENU__', `<div id="nav">
 <a href="__BASE_ADDRESS__/index.html">Home</a>
 <a href="__BASE_ADDRESS__/packages.html">Packages</a>
 <a href="__BASE_ADDRESS__/developers.html">Developers</a>
 <a href="__BASE_ADDRESS__/docs.html">Documentation</a>
 <a href="__BASE_ADDRESS__/FAQ.html">FAQ</a> 
 <a href="__BASE_ADDRESS__/bugs.html">Bugs</a> 
 <a href="__BASE_ADDRESS__/archive.html">Mailing Lists</a>
 <a href="__BASE_ADDRESS__/links.html">Links</a>
 <a href="__SUMMARY__">SourceForge</a>
 <a href="__DOWNLOAD__">Download</a>
 <a href="__CVS__">CVS</a>
</div>
')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__HEADER__', `__HTML_HEADER__([[[$1]]])
__MENU__
<div id="content">
')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__DOC_HEADER__', `__HTML_HEADER__([[[$1]]])
__MENU__
<div id="nav2">
<form name="docform">
m4_include([[[doc/alphabetic.include]]])
m4_include([[[doc/menu.include]]])
</form>
</div>
<div id="content">
')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__BIG_HEADER__', `__HEADER__($1)
<p>
m4_ifdef(`__TEXT_MODE__',
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
</p>')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__nav_button__',
`ifelse(`$1', `$2',
  `<font color="__NAV_SELECTED_COLOR__">$4</font>',
  `__OCTAVE_HTTP__($3, $4)')')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__ext_nav_button__', `__HTTP__($1, $2)')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__view_button__',
`m4_ifdef(`__TEXT_MODE__',
       `__OCTAVE_GRAPHICS_HTTP__(__FILE_NAME__, `Graphics View')',
       `__OCTAVE_TEXT_HTTP__(__FILE_NAME__, `Text View')')')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__NAVIGATION__', `<small>
<p>
m4_ifdef(`__TEXT_MODE__', `<center>',
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
m4_ifdef(`__TEXT_MODE__', `</center>', `</font></td></tr></table>')
</p>')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__TRAILER__', `
</div>
<div id="sf_logo">
  <a  href="__SOURCEFORGE__"><img src="__SOURCEFORGE__/sflogo.php?__GROUP_ID__&amp;type=1"  width="88"
height="31" style="border: 0;" alt="SourceForge.net Logo"  /></a>
</div>
</body>
</html>')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__OCTAVE_TRAILER__', `__NAVIGATION__(`$1')
__COPYING__
__TRAILER__')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__TITLE_BAR__', `<p>
m4_ifdef(`__TEXT_MODE__',
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
</p>')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__TEXT_DOWNLOAD_INFO__', `<ul>
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
m4_dnl
m4_dnl
m4_dnl
m4_define(`__GRAPHICS_DOWNLOAD_INFO__',
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
</table>')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__DOWNLOAD_INFO__', `<p>
m4_ifdef(`__TEXT_MODE__',
`__TEXT_DOWNLOAD_INFO__($@)',
`__GRAPHICS_DOWNLOAD_INFO__($@)')
</p>
')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`seealso_body', `m4_ifelse(`$#', `0', , `$#', `1', ``<a href="$1.html">$1</a>'',
                               `<a href="$1.html">`$1'</a>, seealso_body(m4_shift($@))')')
m4_define(`seealso', `<div class="see_also">See also: seealso_body($@)</div>')
m4_dnl
m4_dnl
m4_dnl
m4_changequote([[[, ]]])
