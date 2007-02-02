function fix_top_menu()
{
    if (navigator.appVersion.indexOf('MSIE') == -1) {
        document.getElementById("top-menu").style.position = "fixed";
    } // end non-IE
}
