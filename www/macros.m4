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

m4_changequote([[[, ]]])
m4_define([[[__JAVA_SCRIPT_FIXED__]]],
 [[[<script type="text/javascript">
  <!--
  function fix_top_menu() {
    if (navigator.appVersion.indexOf('MSIE') == -1) {
      document.getElementById("top-menu").style.position = "fixed";
    } // end non-IE
  }
  // -->
  </script>]]])m4_dnl
m4_dnl
m4_define([[[__JAVA_SCRIPT__]]],
 [[[  __JAVA_SCRIPT_FIXED__
  <script type="text/javascript">
  <!--
  var cookie_name = "octave_forge_cookie";
  function set_cookie(val) {
    if (document.cookie != document.cookie) {
      index = document.cookie.indexOf(cookie_name);
    } else {
      index = -1;
    }
    if (index == -1) {
      var cval = cookie_name + "=" + val + "; ";
      var d = new Date();
      d.setSeconds(d.getSeconds()+30);
      cval = cval + "expires=" + d.toString() + ";";
      document.cookie = cval;
    }
  }
  function get_cookie() {
    var retval = -1;
    if (document.cookie) {
      var index = document.cookie.indexOf(cookie_name);
      if (index != -1) {
        var start = document.cookie.indexOf("=", index) + 1;
        stop = document.cookie.indexOf(";", start);
        if (stop == -1) {
          stop = document.cookie.length;
        }
        retval = document.cookie.substring(start, stop);
      }
    }
    return retval;
  }
  function goto_url (selSelectObject) {
    if (selSelectObject.options[selSelectObject.selectedIndex].value != "-1") {
     location.href=selSelectObject.options[selSelectObject.selectedIndex].value;
    }
  }
  function unfold(id) {
    document.getElementById(id).style.display = "none";
    document.getElementById(id+"_detailed").style.display = "block";
  }
  function fold(id) {
    document.getElementById(id+"_detailed").style.display = "none";
    document.getElementById(id).style.display = "block";
  }
  function switch_to(id) {
    set_cookie(id);
    if (id == "cat") {
        other = "alpha-tab";
        left = "2";
        right = "1";
    } else { // id == "alpha"
        other = "cat-tab";
        left = "1";
        right = "2";
    }
    id = id + "-tab";
    var tab1 = document.getElementById(id);
    var tab2 = document.getElementById(other);

    tab1.style.borderTop    = "2px solid black";
    tab1.style.borderLeft   = "2px solid black";
    tab1.style.borderRight  = right+"px solid black";
    tab1.style.borderBottom = "2px solid #EEEEEE";
    tab2.style.borderTop    = "1px solid black";
    tab2.style.borderLeft   = left+"px solid black";
    tab2.style.borderRight  = "1px solid black";
    tab2.style.borderBottom = "2px solid black";

    tab1.style.fontWeight = "bold";
    tab2.style.fontWeight = "normal";
    
    tab1.style.background = "#EEEEEC";
    tab2.style.background = "transparent";
  }
  function switch_to_cat() {
    switch_to("cat");
    var d = document.getElementById("menu-contents");
    d.innerHTML = '\
    m4_include([[[doc/menu.include]]])';
  }
  function switch_to_alpha() {
    switch_to("alpha");
    var d = document.getElementById("menu-contents");
    d.innerHTML = '\
    m4_include([[[doc/alphabetic.include]]])';
  }
  function write_left_menu() {
    // Only do this if we are running non-IE browsers
    if (navigator.appVersion.indexOf('MSIE') == -1) {
      menuhtml = '<div id="left-switcher">\
                    <div class="tab" id="cat-tab" onclick="javascript:switch_to_cat()">\
                      <a href="javascript:switch_to_cat();" style="text-decoration: none;">Categorical</a>\
                    </div>\
                    <div class="tab" id="alpha-tab" onclick="javascript:switch_to_alpha()">\
                      <a href="javascript:switch_to_alpha();" style="text-decoration: none;">Alphabetical</a>\
                    </div>\
                    <div id="menu-contents" class="left-menu" style="position: fixed; overflow: auto;">\
                    </div>\
                  </div>';
      var left_menu_span = document.getElementById("left-menu-span");
      left_menu_span.innerHTML = menuhtml;
      var cat_tab = document.getElementById("cat-tab");
      var alpha_tab = document.getElementById("alpha-tab");
      cat_tab.style.width = "7.5em";
      cat_tab.style.position = "absolute";
      cat_tab.style.bottom = "-4px";
      alpha_tab.style.width = "7.5em";
      alpha_tab.style.position = "absolute";
      alpha_tab.style.bottom = "-4px";
    } // end non-IE
    var tab = get_cookie();
    if (tab == "alpha") {
      switch_to_alpha();
    } else {
      switch_to_cat();
    }
  }
  // -->
  </script>]]])m4_dnl
m4_changequote(`, ')
m4_dnl
m4_dnl
m4_dnl
m4_define(`__BODY__', `<body onload="javascript:fix_top_menu();">')
m4_dnl
m4_define(`__DOC_BODY__', `<body onload="javascript:fix_top_menu(); write_left_menu();">')
m4_dnl
m4_dnl
m4_dnl
m4_define(`__TOP_MENU__',
 `<div id="top-menu" class="menu"> 
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
  </div>')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__HTML_HEADER__', `<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
  <head>
  <meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
  <title>$1</title>
  <link rel="stylesheet" type="text/css" href="__BASE_ADDRESS__/octave-forge.css" />
  __JAVA_SCRIPT__
  </head>
  __BODY__
  __TOP_MENU__([[[$1]]])
')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__DOXY_HEADER__', `<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
  <html>
  <head>
  <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">
  <title>$1</title>
  <link rel="stylesheet" type="text/css" href="__BASE_ADDRESS__/doxygen.css">
  <link rel="stylesheet" type="text/css" href="__BASE_ADDRESS__/octave-forge.css">
  __JAVA_SCRIPT_FIXED__
  </head>
  __BODY__
  __TOP_MENU__([[[$1]]])
  <div id="content">
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
m4_define(`__DOC_HEADER__', `<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
  <head>
  <meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
  <title>$1</title>
  <link rel="stylesheet" type="text/css" href="__BASE_ADDRESS__/octave-forge.css" />
  __JAVA_SCRIPT__
  </head>
  __DOC_BODY__
  __TOP_MENU__([[[$1]]])
<div id="left-menu-span">
<!--[if IE]>
<table id="left-menu">
  <tr><td>
    <div class="tab" id="cat-tab">
    <a href="javascript:switch_to_cat();" style="text-decoration: none;">Categorical</a>
    </div>
  </td><td>
    <div class="tab" id="alpha-tab">
    <a href="javascript:switch_to_alpha();" style="text-decoration: none;">Alphabetical</a>
    </div>
  </td></tr>
  <tr><td colspan="2">
    <div id="menu-contents">
    </div>
  </td></tr>
</table>
<![endif]-->
</div>
<div id="doccontent">
')m4_dnl
m4_dnl
m4_dnl
m4_dnl
m4_define(`__TRAILER__', `
<div id="sf_logo">
  <a href="http://sourceforge.net"><img src="http://sourceforge.net/sflogo.php?group_id=2888&amp;type=1"
     width="88" height="31" style="border: 0;" alt="SourceForge.net Logo"/></a>
</div>
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
