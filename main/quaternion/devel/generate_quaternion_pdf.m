homedir = pwd ();
develdir = fileparts (which ("generate_quaternion_pdf"));
pdfdir = [develdir, "/pdfdoc"];
cd (pdfdir);

collect_texinfo_strings

for i = 1:5
  system ("pdftex -interaction batchmode quaternion.tex");
  system ("texindex quaternion.fn");
endfor

cd (homedir);
