DOCUMENT_ROOT=/var/www QUERY_STRING="x=50%2C1,2&y=1,2,3&len=10&name=test&field=random_field" octave <<EOF
addpath('/home/abarth/Octave/octave-forge/extra/cgi/inst/');

CGI = cgi()
cgi.form.y


EOF