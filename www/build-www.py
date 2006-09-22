#!/usr/bin/env python

import sys
import os
import shutil

## This function parses a DESCRIPTION file
def parse_description(filename):
    try:
        fid = open(filename, 'r');
        keyword = "";
        desc = {};
        line = fid.readline();
        while (line != ""):
            ## Comments
            if (line[0] == "#"):
                # Do nothing
                print("Skip");
            ## Continuation lines
            elif (line[0].isspace()):
                if (keyword != "" & desc.has_key(keyword)):
                    desc[keyword] += line;
            ## Keyword/value pair
            else:
                colon = line.find(":");
                if (colon == -1):
                    print "Skipping line";
                else:
                    keyword = line[0:colon].strip().lower();
                    value = line[colon+1:];
                    if (len(value) == 0):
                        print("The keyword " + keyword + " has an empty value\n.");
                        fid.close();
                        return;
                    desc[keyword] = value.strip();
            line = fid.readline();
        fid.close();
        return desc;
    except:
        print("Couldn't parse the DESCRIPTION file " + filename);
        raise

def create_INDEX(desc, packdir):
    try:
        wd = os.getcwd();
        name_version = desc['name'] + "-" + desc['version'];
        
        ## Create a tarball to be installed
        install_dir = wd + "/install/";
        tarball = name_version + ".tgz";
        if (os.system("tar -zcf " + tarball + " -C " + packdir + "/.. " + desc['name']) != 0):
            raise Exception("Can't create tarball"); 
        
        ## Run octave installation
        command = 'global OCTAVE_PACKAGE_PREFIX="' + install_dir + '"; ';
        command = command + 'pkg("install", "-nodeps", "' + tarball + '");';
        if (os.system("HOME=" + wd + "; octave -H -q --no-site-file --no-init-file --eval '" + command + "'") != 0):
            raise Exception("Can't run Octave"); 
        
        ## Copy the INDEX file to packdir
        shutil.copy2(install_dir + name_version + "/packinfo/INDEX", packdir + "/INDEX");
    
        ## Clean up
        command = 'global OCTAVE_PACKAGE_PREFIX="' + install_dir + '"; ';
        command = command + 'pkg("uninstall", "-nodeps", "' + desc['name'] + '");';
        if (os.system("HOME=" + wd + "; octave -H -q --no-site-file --no-init-file --eval '" + command + "'") != 0):
            raise Exception("Can't run Octave"); 
        os.system("rm -rf " + install_dir + " " + tarball);
    except:
        raise;

## Creates the index.html files for a package in packdir.
## The result is placed in outdir.
def create_index_html(packdir, outdir):
    try:
        desc = parse_description(packdir + "/DESCRIPTION");
    except:
        raise;
    
    ## Write header
    fid = open(outdir + "/index.in", "w");
    fid.write("__HEADER__([[[The " + desc['name'] + " package]]])");

    ## Write important data
    fid.write('    <table id="main_package_table">\n');
    fid.write('      <tr><td>Package Name:</td><td>'       + desc["name"]       + "</td></tr>\n");
    fid.write('      <tr><td>Package Version:</td><td>'    + desc["version"]    + "</td></tr>\n");
    fid.write('      <tr><td>Last Release Date:</td><td>'  + desc["date"]       + "</td></tr>\n");
    fid.write('      <tr><td>Package Author:</td><td>'     + desc["author"]     + "</td></tr>\n");
    fid.write('      <tr><td>Package Maintainer:</td><td>' + desc["maintainer"] + "</td></tr>\n");
    fid.write('      <tr><td colspan="2"><img src="../download.png" alt="Download"/>');
    fid.write('<a href="">Download this package</a></td></tr>\n');
    fid.write('      <tr><td colspan="2"><img src="../doc.png" alt="Documentation"/>');
    fid.write('<a href="../doc/' + desc['name'].lower() + '.html">Read package documentation</a></td></tr>\n');
    fid.write("    </table>\n");
    fid.write('    <div id="description_box">\n');
    if (desc.has_key("html-file")):
        html_fid = open(packdir + "/" + desc["html-file"].strip(), "r");
        fid.write("    " + html_fid.read() + "\n");
        html_fid.close();
    else:
        fid.write("    " + desc["description"] + "\n");
    fid.write('    </div>\n\n');
    
    ## Write less important data
    keys = desc.keys();
    fid.write("    <h3>Other information</h3>\n");
    fid.write('    <table id="extra_package_table">\n');
    ## License
    fid.write('      <tr><td>License: </td><td><a href="license.html">');
    if (desc.has_key("license")):
        fid.write(desc['license']);
    else:
        fid.write('details');
    fid.write('</a></td></tr>\n');
    ## URL
    if (desc.has_key("url")):
        fid.write('      <tr><td>Web page: </td><td><a href="' + desc['url'] + '">');
        fid.write(desc['url']);
        fid.write('</a></td></tr>\n');
    ## Dependencies
    if (desc.has_key("depends")):
        fid.write('      <tr><td>Dependencies: </td><td>');
        fid.write(desc['depends']);
        fid.write('</td></tr>\n');
    ## Everything else
    already_shown_keys = ["title", "name", "version", "date", "author", 
                          "maintainer", "description", "html-file", 
                          "license", "url", "depends"];
    for k in keys:
        if (already_shown_keys.count(k) == 0):
            value = desc[k];
            fid.write("      <tr><td>" + k + ":</td><td>" + value + "</td></tr>\n");
    fid.write("    </table>\n");
    
    ## Write footer
    fid.write("__TRAILER__\n");
    fid.close();
    
    ## Check if the package has an INDEX file (if not create one)
    INDEX_file = packdir + "/INDEX";
    if (not os.path.isfile(INDEX_file)):
        create_INDEX(desc, packdir);
    
    return desc;

def create_license_html(package_name, packdir, outdir):
    ## Read License
    filename = packdir + "/COPYING";
    fid = open(filename, 'r');
    license = fid.readlines();
    fid.close();

    ## Write output
    fid = open(outdir + "/license.in", "w");
    fid.write("__HEADER__([[[The " + package_name + " package]]])\n");
    fid.write("<h3>The license terms for the " + package_name + " package are as follows</h3>\n");
    fid.write('<p><textarea rows="20" cols="80" readonly>');
    for c in license:
        fid.write(c)
    fid.write('</textarea></p>\n');
    fid.write('<p><a href="index.html">Back to the package page</a></p>\n');
    fid.write("__TRAILER__\n");
    fid.close();


def rm_rf(p):
    #print("Deleting " + p);
    if (p == "./CVS"):
        return;
    for root, dirs, files in os.walk(p, topdown=False):
        for name in files:
            os.remove(os.path.join(root, name));
        for name in dirs:
            os.rmdir(os.path.join(root, name));
    os.rmdir(p);

def handle_package(packdir, outdir):
    if (os.path.isdir(packdir)):
        if (os.path.exists(outdir)):
            rm_rf(outdir);
        os.mkdir(outdir);
        try:
            desc = create_index_html(packdir, outdir);
            create_license_html(desc['name'], packdir, outdir);
            return desc;
        except:
            rm_rf(outdir);
            raise Exception("Can't create index.html");
    raise Exception('not packdir');

def main():
    ## Start the package file
    index = open("packages.in", "w");
    index.write("__HEADER__([[[Packages]]])");
    index.write('<p>The following packages are currently available in the repository.\n');
    index.write("If you don't know how to install the packages please read the\n");
    index.write('relevant part of the <a href="FAQ.html#install">FAQ</a>.\n</p>');
    index.write('<p>Currently Octave-Forge is divided into seperate repositories\n');
    index.write('<ul><li><a href="#main">Main repository</a> contains packages that\n');
    index.write('are well tested and suited for most users.</li>\n');
    index.write('<li><a href="#extra">Extra packages</a> contains packages that\n');
    index.write("for various reasons aren't suited for everybody.</li>\n");
    index.write('<li><a href="#nonfree">Non-free packages</a> contains packages\n');
    index.write('that have license issues. Usually the packages themselves are\n');
    index.write('Free Software that depend on non-free libraries.</li></ul>\n');
    
    main_dirs = ["main",            "extra",          "nonfree"];
    headers   = ["Main repository", "Extra packages", "Non-free packages"];
    for i in range(len(main_dirs)):
        name = main_dirs[i];
        main_dir = "../"  + name + "/";
        header = headers[i];
        packages = os.listdir(main_dir);
        
        index.write('<h2 id="' + name + '">' + header + '</h2>\n');
        
        for i in range(0, len(packages)):
            p = packages[i];
            packdir = main_dir + p;
            outdir  = "./" + p;
            try:
                desc = handle_package(packdir, outdir);
                index.write('<div class="package">\n');
                index.write('  <b>' + desc['name'] + '</b>\n');
                index.write('<p>' + desc['description'][:100]);
                if (len(desc['description']) > 100):
                    index.write('...');
                index.write('</p>\n');
                index.write('<p class="package_link">&raquo; <a href="' + outdir + '/index.html">details</a> | ');
                index.write('<a href="' + outdir + '/index.html">download</a></p>\n');
                index.write('</div>\n');
            except Exception, e:
                print("Skipping " + p);
                print(e)
    
    index.write('__TRAILER__\n');
    index.close();

main();

