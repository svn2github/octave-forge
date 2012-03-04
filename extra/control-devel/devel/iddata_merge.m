%u = iddata ({(1:10).', (21:30).'}, {(41:50).', (61:70).'});
%v = iddata ({(11:20).', (31:40).'}, {(51:60).', (71:80).'});

oy = ones (200, 5);
ou = ones (200, 4);
y = repmat ({oy}, 6, 1);
u = repmat ({ou}, 6, 1);

u = iddata (y, u)
v = u

a = [u, v]
b = [u; v]
c = merge (u, v)