dat = iddata ((1:10).', (21:30).')

a = iddata ({(1:10).', (21:30).'}, {(31:40).', (41:50).'})

b = iddata ({(1:10).', (21:30).'}, [])

c = iddata ({(1:10).', (21:40).'}, {(31:40).', (41:60).'})

x = c;
%x.y = {}

%x.u = []
x.u = x.y