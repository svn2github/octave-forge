i = ones (3, 3);

w = 2*i;
x = 3*i;
y = 4*i;
z = 5*i;

q = quaternion (w, x, y, z)

q .* conj (q)


%{

octave:1> quaternion_matrices 
q.w =
   2   2   2
   2   2   2
   2   2   2

q.x =
   3   3   3
   3   3   3
   3   3   3

q.y =
   4   4   4
   4   4   4
   4   4   4

q.z =
   5   5   5
   5   5   5
   5   5   5

ans.w =
   54   54   54
   54   54   54
   54   54   54

ans.x =
   0   0   0
   0   0   0
   0   0   0

ans.y =
   0   0   0
   0   0   0
   0   0   0

ans.z =
   0   0   0
   0   0   0
   0   0   0

octave:2> 

%}