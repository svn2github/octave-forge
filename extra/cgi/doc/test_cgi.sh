export DOCUMENT_ROOT=/var/www 
export REQUEST_METHOD=GET
export QUERY_STRING="x=50%2C1,2&y=1,2,3&len=10&name=test&field=random_field" 

echo "Test GET request"
octave -q <<EOF
CGI = cgi();
disp(CGI.form.y)
assert(strcmp(CGI.form.y,'1,2,3'))
assert(strcmp(CGI.form.field,'random_field'))
disp('All tests passed');
EOF

echo "Test GET request (with semicolon)"

export QUERY_STRING="x=50%2C1,2;y=1,2,3;len=10;name=test;field=random_field" 

octave -q <<EOF
CGI = cgi();
assert(strcmp(CGI.form.y,'1,2,3'))
assert(strcmp(CGI.form.field,'random_field'))
disp('All tests passed');
EOF

echo "Test POST request"

export DOCUMENT_ROOT=/var/www 
export REQUEST_METHOD=POST 
export CONTENT_TYPE=application/x-www-form-urlencoded
export CONTENT_LENGTH=54

echo "x=50%2C1,2&y=1,2,3&len=10&name=test&field=random_field" | \
    octave -qH --eval "CGI = cgi(); assert(strcmp(CGI.form.y,'1,2,3')); disp('All tests passed');";

