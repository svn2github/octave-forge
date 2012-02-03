 QQ = { qnmknode( "m/m/m-fcfs", [0.2 0.1 0.1; 0.2 0.1 0.1] ), \
        qnmknode( "-/g/1-ps", [0.4; 0.6] ), \
        qnmknode( "-/g/inf", [1; 2] ) };
 V = [ 1 0.6 0.4; \
       1 0.3 0.7 ];
 N = [ 2 1 ];
 [U R Q X] = qnsolve( "closed", N, QQ, V );