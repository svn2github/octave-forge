dat = iddata ((1:10).', (21:30).')

a = iddata ({(1:10).', (21:30).'}, {(31:40).', (41:50).'})

b = iddata ({(1:10).', (21:30).'}, [])

c = iddata ({(1:10).', (21:40).'}, {(31:40).', (41:60).'})

x = c;
%x.y = {}

%x.u = []
x.u = x.y

d = iddata ({(1:10).', (21:25).'}, {(31:40).', (41:45).'})

e = iddata ({(1:10).', (21:25).', (21:125).'}, {(31:40).', (41:45).', (41:145).'})


oy = ones (200, 5);
ou = ones (200, 4);
y = repmat ({oy}, 6, 1);
u = repmat ({ou}, 6, 1);

f = iddata (y, u)
%{
f.expname = strseq ("experiment", 1:6)
f.expname(2) = "value 1"
f.expname{2} = "value 2"
%}

%cat (4, f, f, f)

%cat (1, f, f)

u = iddata ({(1:10).', (21:30).'}, {(41:50).', (61:70).'});
v = iddata ({(11:20).', (31:40).'}, {(51:60).', (71:80).'});


w = cat (1, u, v)

cat (3, d, e)


un = iddata ({(1:10).', (21:30).'}, {(41:50).', (61:70).'}, [], "expname", strseq ("alpha", 1:2));
vn = iddata ({(11:20).', (31:40).'}, {(51:60).', (71:80).'}, [], "expname", strseq ("beta", 1:2));
n = [un; vn]
