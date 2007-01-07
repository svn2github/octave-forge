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
m4_define(`__DEFAULT_LINK_TEXT__', `m4_ifelse($#, 2, [[[$1://$2]]], [[[$3]]])')m4_dnl
m4_define(`__HTTP__',
       `<a href="$1" class="menu">__DEFAULT_LINK_TEXT__([[[http]]], $*)</a>')m4_dnl
m4_define(`__MAILTO__',
       ``<a href="mailto:$1">'__DEFAULT_LINK_TEXT__(`http', $*)`</a>'')m4_dnl
m4_define(`__FTP__',
       ``<a href="ftp://$1">'__DEFAULT_LINK_TEXT__(`http', $*)`</a>'')m4_dnl
m4_dnl
m4_define(`__OCTAVE_IMAGE__',
       ``<img src="'__IMAGE_DIR__`$1" alt="[$2]" ' ifelse($#, 3, `$3')`>'')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__OCTAVE_FORGE_HTTP__',
       `<a href="__BASE_ADDRESS__/$1" class="menu">$2</a>')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__HTML_HEADER__', `<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
  <head>
  <meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
  <title>$1</title>
  <link rel="stylesheet" type="text/css" href="__BASE_ADDRESS__/doxygen.css" />
  <link rel="stylesheet" type="text/css" href="__BASE_ADDRESS__/octave-forge.css" />
  <script type="text/javascript">
  <!--
  function goto_url (selSelectObject) {
    if (selSelectObject.options[selSelectObject.selectedIndex].value != "-1") {
     location.href=selSelectObject.options[selSelectObject.selectedIndex].value;
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
  function switch_to(id) {
    if (id == "cat") {
        other = "alpha";
    } else { // id == "alpha"
        other = "cat";
    }

    document.getElementById(id).style.visibility = "visible";
    document.getElementById(other).style.visibility = "hidden";

    document.getElementById(id+"-tab").style.border = "solid 2px";
    document.getElementById(id+"-tab").style.borderBottom = "none";
    document.getElementById(other+"-tab").style.border = "solid 1px";
    document.getElementById(other+"-tab").style.borderBottom = "solid 2px";

    document.getElementById(id+"-tab").style.height = "1.3em";
    document.getElementById(other+"-tab").style.height = "1.2em;";

    document.getElementById(id+"-tab").style.zIndex = "3";
    document.getElementById(other+"-tab").style.zIndex = "2";

    document.getElementById(id+"-tab").style.fontWeight = "bold";
    document.getElementById(other+"-tab").style.fontWeight = "normal";
  }
  function switch_to_cat() {
    switch_to("cat");
  }
  function switch_to_alpha() {
    switch_to("alpha");
  }
  // -->
  </script>
  </head>

<body>

  <div id="top-menu" class="menu"> 
   <table class="menu">
      <tr>
        <td style="width: 90px;" class="menu" rowspan="2">
          <a name="top">
          <img src="__BASE_ADDRESS__/oct.png" alt="Octave logo" />
          </a>
        </td>
        <td class="menu" style="padding-top: 0.9em;">
          <big class="menu">Octave-Forge</big><small class="menu"> - Extra packages for GNU Octave</small>
        </td>
      </tr>
      <tr>
        <td class="menu">
          __MENU__([[[$1]]])
        </td>
      </tr>
    </table>
   </div>
')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__nav_button__',
`m4_ifelse($1, $2,
  [[[<b>$4</b>]]],
  [[[__OCTAVE_FORGE_HTTP__($3, $4)]]])')m4_dnl
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
m4_define(`__MENU__', `
 __nav_button__($1, [[[Octave-Forge]]], [[[index.html]]], [[[Home]]]) &middot;
 __nav_button__($1, [[[Packages]]], [[[packages.html]]], [[[Packages]]]) &middot;
 __nav_button__($1, [[[Developer Notes]]], [[[developers.html]]], [[[Developers]]]) &middot;
 __nav_button__($1, [[[Documentation]]], [[[docs.html]]], [[[Documentation]]]) &middot;
 __nav_button__($1, [[[Function Reference]]], [[[doc/index.html]]], [[[Function Reference]]]) &middot;
 __nav_button__($1, [[[Frequently Asked Questions]]], [[[FAQ.html]]], [[[FAQ]]]) &middot;
 __nav_button__($1, [[[Bugs]]], [[[bugs.html]]], [[[Bugs]]]) &middot;
 __nav_button__($1, [[[Mailing List]]], [[[archive.html]]], [[[Mailing Lists]]]) &middot;
m4_dnl __nav_button__($1, [[[Octave-Forge News Archive]]], [[[NEWS.html]]], [[[News Archive]]]) &middot;
 __nav_button__($1, [[[Links]]], [[[links.html]]], [[[Links]]]) &middot;
m4_dnl __ext_nav_button__([[[__SUMMARY__]]], [[[SourceForge]]]) &middot;
m4_dnl __ext_nav_button__([[[__DOWNLOAD__]]], [[[Download]]]) &middot;
 __ext_nav_button__([[[__CVS__]]], [[[CVS]]])
')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__HEADER__', `__HTML_HEADER__([[[$1]]])
<div id="content">
')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__DOC_HEADER__', `__HTML_HEADER__([[[$1]]])

<div id="left-switcher">
  <div class="tab" id="cat-tab" onclick="javascript:switch_to_cat();">
    Categorical
  </div>
  <div class="tab" id="alpha-tab" onclick="javascript:switch_to_alpha();">
    Alphabetical
  </div>
</div> 
<div id="cat" class="left-menu">
m4_include([[[doc/menu.include]]])
</div>
<div id="alpha" class="left-menu" style="visibility: hidden;">
m4_include([[[doc/alphabetic.include]]])
</div>
<div id="doccontent">
')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__TRAILER__', `
</div>
<div id="sf_logo">
  <a href="http://sourceforge.net"><img src="http://sourceforge.net/sflogo.php?group_id=2888&amp;type=1"
     width="88" height="31" style="border: 0;" alt="SourceForge.net Logo"/></a>
</div>
</body>
</html>')m4_dnl
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
