include "globals.mzn";

int: n;
set of int: N = 1..n;
int: ub;
set of int: UB = 1..ub; % set of ints from 1 to the upper bound

% ================= GRID CONSTRAINTS  ==================== %
array[0..(n*n)] of var bool: grid;
constraint grid[1] = false;
constraint grid[(n*n)-n+1] = false; 

% must be obstacle in first column
constraint sum([grid[(i*n)-n+1]  | i in 2..(n-1)]) > 0;

%at most n-1 obs in each row TODO - readd this with n - (n/3) instead of n-1 and for rows and columns.
constraint forall(i in 1..n) (
  sum([grid[j]  | j in ((i-1)*n)+1..(n)*i]) < n
);

% ========================================================= %

% =============== VISITS CONSTRAINTS (eq13) ================== %


array[1..ub] of var bool: stayStill; 

%represents the cell squeaky is at, for any given timestep
array[1..ub] of var 1..n*n: location; 
constraint location[1] = 1;

array[1..ub] of var bool: moveDown; 
constraint moveDown[1] = true;
constraint forall(i in 2..ub) ( 
  moveDown[i] = 
  ((count([location[l] | l in 1..i-1], location[i-1]+n) <= count([location[l] | l in 1..i-1], location[i-1]+1) \/ grid[location[i-1]+1] == true \/ 'mod'(location[i-1],n) == 0) /\ 
  (count([location[l] | l in 1..i-1], location[i-1]+n) <= count([location[l] | l in 1..i-1], location[i-1]-1) \/ grid[location[i-1]-1] == true \/ 'mod'(location[i-1],n) == 1) /\ 
  (count([location[l] | l in 1..i-1], location[i-1]+n) <= count([location[l] | l in 1..i-1], location[i-1]-n) \/ grid[location[i-1]-n] == true  \/ location[i-1] <  n+1) /\ 
  grid[location[i-1]+n] == false /\
  location[i-1]  < (n*n - n+1))
);

array[1..ub] of var bool: moveRight; 
constraint moveRight[1] = false;
%visits[location[i-1]+1,i-1]
constraint forall(i in 2..ub) ( 
  moveRight[i] = 
  ((count([location[l] | l in 1..i-1], location[i-1]+1) < count([location[l] | l in 1..i-1], location[i-1]+n)  \/ grid[location[i-1]+n] == true \/ location[i-1] > (n*n)-n) /\ 
  (count([location[l] | l in 1..i-1], location[i-1]+1) <= count([location[l] | l in 1..i-1], location[i-1]-1)  \/ grid[location[i-1]-1] == true \/ 'mod'(location[i-1],n) == 1) /\ 
  (count([location[l] | l in 1..i-1], location[i-1]+1) <=count([location[l] | l in 1..i-1], location[i-1]-n)  \/ grid[location[i-1]-n] == true \/ location[i-1] < n + 1) /\ 
  grid[location[i-1]+1] == false /\ 
  'mod'(location[i-1],n) != 0 /\
  location[i-1] != ((n*n)-n+1)) 
);


array[1..ub] of var bool: moveLeft; 
constraint moveLeft[1] = false;
constraint forall(i in 2..ub) ( 
  moveLeft[i] = 
  ((count([location[l] | l in 1..i-1], location[i-1]-1) < count([location[l] | l in 1..i-1], location[i-1]+n) \/ grid[location[i-1]+n] == true \/ location[i-1] > (n*n)-n) /\ 
  (count([location[l] | l in 1..i-1], location[i-1]-1) < count([location[l] | l in 1..i-1], location[i-1]+1) \/ grid[location[i-1]+1] == true \/ 'mod'(location[i-1],n) == 0) /\ 
  (count([location[l] | l in 1..i-1], location[i-1]-1) <= count([location[l] | l in 1..i-1], location[i-1]-n) \/ grid[location[i-1]-n] == true \/ location[i-1] < n+1) /\ 
  grid[location[i-1]-1] == false /\  
  'mod'(location[i-1],n) != 1)
);


array[1..ub] of var bool: moveUp; 
constraint moveUp[1] = false;
constraint forall(i in 2..ub) (
  moveUp[i] = 
  ((count([location[l] | l in 1..i-1], location[i-1]-n) < count([location[l] | l in 1..i-1], location[i-1]+n) \/ grid[location[i-1]+n] == true \/ location[i-1] > (n*n)-n) /\ 
  (count([location[l] | l in 1..i-1], location[i-1]-n) < count([location[l] | l in 1..i-1], location[i-1]+1) \/ ('mod'(location[i-1],n) == 0) \/ grid[location[i-1]+1] == true) /\ 
  (count([location[l] | l in 1..i-1], location[i-1]-n) < count([location[l] | l in 1..i-1], location[i-1]-1) \/ grid[location[i-1]-1] == true \/ ('mod'(location[i-1], n) == 1)) /\ 
  grid[location[i-1]-n] == false /\ 
  location[i-1] != ((n*n)-n+1) /\
  location[i-1]  > n)
);

%stay still if at finish, else move based on movement arrays
constraint forall(i in 2..ub) (
   location[i] = (((location[i-1]+1) * bool2int(moveRight[i])) + ((location[i-1]-1) * bool2int(moveLeft[i])) + ((location[i-1]-n) * bool2int(moveUp[i])) + ((location[i-1]+n) * bool2int(moveDown[i])) + (stayStill[i] * ((n * n) - n +1)))
);

constraint forall(i in 2..ub) (
   if location[i-1] == ((n*n)-n+1)
    then stayStill[i] = 1
   else 
     stayStill[i] = 0
   endif
);
% ========================================================= %

% =================== Objective function ======================== %
constraint visits[(n*n)-n+1,ub] > 0;
solve minimize (count([location[i] | i in 1..ub], (n*n) - n + 1));

%grid
output[if 'mod'(j,n) == 0 then show(bool2int(grid[(i-1)*n+j])) ++"\n" else show(bool2int(grid[(i-1)*n+j])) ++ " " endif | i in 1..n, j in 1..n];