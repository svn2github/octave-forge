[ac, pn, ref] = loadwing ('cesar_wing');
pols = loadpolars (pn);
wing = makewing (ac, pols, ref, 64);

#AC = [wing.xac wing.yac wing.zac];
#CP = (AC(1:end-1,:) + AC(2:end,:))/2;
#
#i = 3; j = 3;
#flw.vyg (i,j)
#vi = horseshoe (AC(j,:), AC(j+1,:), 0, CP(i,:));
#vi -= horseshoe (-AC(j,:), -AC(j+1,:), 0, CP(i,:))

clq = calcwing (wing, "tol", 1e-4);

