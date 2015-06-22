export DOCUMENT_ROOT=/var/www 
export REQUEST_METHOD=POST 
export CONTENT_TYPE=multipart/form-data

# from http://www.w3.org/TR/html401/interact/forms.html#h-17.13.4.2

octave -q --eval test_cgi_upload <<EOF
Content-Type: multipart/form-data; boundary=AaB03x

--AaB03x
Content-Disposition: form-data; name="submit-name"

Larry
--AaB03x
Content-Disposition: form-data; name="files"; filename="file1.txt"
Content-Type: text/plain

... contents of file1.txt ...
--AaB03x--
EOF



