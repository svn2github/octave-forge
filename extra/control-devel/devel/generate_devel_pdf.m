homedir = pwd ();
develdir = fileparts (which ("generate_devel_pdf"));
pdfdir = [develdir, "/pdfdoc"];
cd (pdfdir);

collect_texinfo_strings

for i = 1:5
  system ("pdftex -interaction batchmode control-devel.tex");
endfor

cd (homedir);
