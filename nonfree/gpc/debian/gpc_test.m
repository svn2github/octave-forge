### Read subject and clip polygons
s = gpc_read ("/usr/share/doc/libgpcl-dev/examples/subj1.gpf");
c = gpc_read ("/usr/share/doc/libgpcl-dev/examples/clip1.gpf");

### Compute clipping poligon (intersection)
r = gpc_clip (s,c);

### Plot the polygons
gset nokey
gset size square
gset terminal x11
hold off
gpc_plot (s, "r");
gpc_plot (c, "g");
gpc_plot (r, "b");

