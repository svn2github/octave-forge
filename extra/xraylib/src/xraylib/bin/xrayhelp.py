import string

def display_func(func_name):
    fp = open('../doc/xrayhelp.txt', 'r')
    file_lines = fp.readlines()
    fp.close()
    for i in range(len(file_lines)):
        line = string.strip(file_lines[i])
        if (line == func_name):
            while (line != ""):
                i = i + 1
                line = string.strip(file_lines[i])
                print line
            return
    print
    print "Function not recognized"
    print




