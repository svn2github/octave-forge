ann

pts=[-0.297462,0.176102;
0.565538,-0.361496;
0.909313,-0.182785;
0.920712,0.478408;
0.167682,0.0499836;
0.305223,-0.0805835;
0.114973,0.882453;
0.742916,0.16376;
0.0724605,-0.826775;
0.690960,-0.559284;
0.188485,-0.643934;
0.749427,-0.942415;
-0.970662,-0.223466;
0.916110,0.879597;
0.927417,-0.382593;
-0.711327,0.278713;
-0.519172,0.986146;
0.135338,0.924588;
-0.0837537,0.61687;
0.0520465,0.896306;
];

querypts=[
0.0902484,-0.207129;
-0.419567,0.485743;
0.826225,-0.30962;
0.694758,0.987088;
-0.410807,-0.465182;
-0.836501,0.490184;
0.588289,0.656408;
0.325807,0.38721;
-0.532226,-0.727036;
-0.52506,-0.853508;
];

kd=ANNkd_tree(10,128)
kd=ANNkd_tree(pts)
assert(kd.theDim()==size(pts,2));
assert(kd.nPoints()==size(pts,1));

kd.Print(true);
kd.Print(false);
kd.Dump(true);
kd.Dump(false);

s=kd.getStats()
s.dim
s.n_pts
s.bkt_size
s.n_lf
s.n_tl
s.n_spl
s.n_shr
s.depth
s.sum_ar
s.avg_ar


[nn_idx,dd]=kd.annkSearch(querypts(4,:),5)
[nn_idx,dd]=kd.annkPriSearch(querypts(4,:),5);
[n,nn_idx,dd]=kd.annkFRSearch(querypts(4,:),2,5);

for i=1:size(querypts,1),
  [nn_idx,dd]=kd.annkSearch(querypts(i,:),5)
endfor

annMaxPtsVisit(10)
