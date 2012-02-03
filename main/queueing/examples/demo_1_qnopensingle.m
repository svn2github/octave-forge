 lambda = 3;
 V = [16 7 8];
 S = [0.01 0.02 0.03];
 [U R Q X] = qnopensingle( lambda, S, V );
 R_s = dot(R,V) # System response time
 N = sum(Q) # Average number in system