#!/usr/bin/env python

import os

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

## Creates the index.html files for a package in packdir.
## The result is placed in outdir.
def create_index_html(packdir, outdir):
    try:
        desc = parse_description(packdir + "/DESCRIPTION");
    except:
        raise;
    
    ## Write header
    fid = open(outdir + "/index.html", "w");
    fid.write('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">\n');
    fid.write('<html lang="en">\n');
    fid.write('  <head>\n');
    fid.write('    <title>Octave-Forge: ' + desc['name'] + '</title>\n');
    fid.write('    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">\n');
    fid.write('    <link type="text/css" rel="stylesheet" href="http://octave.org/octave.css">\n');
    fid.write('    <link type="text/css" rel="stylesheet" href="../package.css">\n');
    fid.write('  </head>\n\n');
    fid.write('  <body>\n');
    
    ## Write important data
    fid.write("    <h2>" + desc["title"] + "</h2>\n");
    fid.write('    <table id="main_package_table">\n');
    fid.write('      <tr><td>Package Name:</td><td>'       + desc["name"]       + "</td></tr>\n");
    fid.write('      <tr><td>Package Version:</td><td>'    + desc["version"]    + "</td></tr>\n");
    fid.write('      <tr><td>Last Release Date:</td><td>'  + desc["date"]       + "</td></tr>\n");
    fid.write('      <tr><td>Package Author:</td><td>'     + desc["author"]     + "</td></tr>\n");
    fid.write('      <tr><td>Package Maintainer:</td><td>' + desc["maintainer"] + "</td></tr>\n");
    fid.write('      <tr><td colspan="2"><img src="../download.png" alt="Download"/><a href="">Download this package</a></td></tr>\n');
    fid.write('      <tr><td colspan="2"><img src="../doc.png" alt="Documentation"/><a href="">Read package documentation</a></td></tr>\n');
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
    already_shown_keys = ["title", "name", "version", "date", "author", "maintainer", "description", "html-file"];
    keys = desc.keys();
    if (len(keys) > len(already_shown_keys)):
        fid.write("    <h3>Other information</h3>\n");
        fid.write('    <table id="extra_package_table">\n');
        for k in keys:
            if (already_shown_keys.count(k) == 0):
                value = desc[k];
                fid.write("      <tr><td>" + k + "</td><td>" + value + "</td></tr>\n");
        fid.write("    </table>\n");
    
    ## Write footer
    fid.write("  </body>\n</html>\n");
    fid.close();

def rm_rf(p):
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
            create_index_html(packdir, outdir)
            return 1;
        except:
            rm_rf(outdir);
            return 0;
    return 0;

def main():
    main_dir = "../main/";
    packages = os.listdir(main_dir);
    
    ## Start main index file
    index = open("index.html", "w");
    index.write('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">\n');
    index.write('<html lang="en">\n');
    index.write('  <head>\n');
    index.write('    <title>Octave-Forge packages</title>\n');
    index.write('    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">\n');
    index.write('    <link type="text/css" rel="stylesheet" href="http://octave.org/octave.css">\n');
    index.write('    <link type="text/css" rel="stylesheet" href="package.css">\n');
    index.write('  </head>\n\n');
    index.write('  <body>\n');
    
    for i in range(0, len(packages)):
        p = packages[i];
        packdir = main_dir + p;
        outdir  = "./" + p;
        s = handle_package(packdir, outdir);
        if (s):
            index.write('<a href="' + outdir + '/index.html">' + p + '</a><br>\n');
        else:
            print("Skipping " + p);

    index.write('  </body>\n</html>\n');
    index.close();

main();

