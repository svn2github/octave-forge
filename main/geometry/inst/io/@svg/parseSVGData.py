#!/usr/bin/env python

import inkex
import sys
#import getopt

def parseSVGData (filen=None):

  svg = inkex.Effect ()
  svg.parse (filen)
  
  root = svg.document.xpath ('//svg:svg', namespaces=inkex.NSS)
  print 'data = struct("height",{0},"width",{1},"id","{2}");' \
        .format(root[0].attrib['height'],root[0].attrib['width'],
                                                          root[0].attrib['id'])
# ----------------------------

if __name__=="__main__":
  svg = sys.argv[1]
  parseSVGData(svg)
