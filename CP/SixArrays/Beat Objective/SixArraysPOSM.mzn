include "globals.mzn";

int: n;
set of int: N = 1..n;
int: ub;
set of int: UB = 1..ub; % set of ints from 1 to the upper bound

% ================= GRID CONSTRAINTS  ==================== %
array[1..(n*n)] of var bool: grid;
constraint grid[1] = false;
constraint grid[(n*n)-n+1] = false; 

% must be obstacle in first column
constraint sum([grid[(i*n)-n+1]  | i in 2..(n-1)]) > 0;

int: obs;
constraint sum([grid[i] | i in 2..(n*n)]) = obs;

% ========================================================= %

% ================= FEASIBILITY CONSTRAINTS  ==================== %

set of int: feasibilityTimesteps = 2..n*n;

array[N, N, 1..n*n] of var bool: moveHereByTimestep;

% start at 1,1
constraint forall(i in N) (
  forall(j in N) (
    if i == 1 /\ j == 1
      then moveHereByTimestep[i,j,1] = true
    else
      moveHereByTimestep[i,j,1] = false
    endif
  )
);

% cells with objects cant be traversed
constraint forall(i in N) (
  forall(j in N) (
    forall(k in feasibilityTimesteps) (
     bool2int(moveHereByTimestep[i,j,k]) <= 1 - bool2int(grid[(i-1)*n+j])
    )
  )
);

constraint forall(i in N) (
  forall(j in N) (
    forall(k in 1..(n*n-1)) (
      if i == 1 /\ j == 1 %topleft
        then bool2int(moveHereByTimestep[i,j,k+1]) >= (bool2int(moveHereByTimestep[i+1,j,k] \/ moveHereByTimestep[i,j+1,k] \/ moveHereByTimestep[i,j,k]) - grid[(i-1)*n+j]) 
      elseif i == 1 /\ j == n %topright
        then bool2int(moveHereByTimestep[i,j,k+1]) >= (bool2int(moveHereByTimestep[i+1,j,k] \/ moveHereByTimestep[i,j-1,k] \/ moveHereByTimestep[i,j,k]) - grid[(i-1)*n+j]) 
      elseif i == n /\ j == 1 %bottomleft
        then bool2int(moveHereByTimestep[i,j,k+1]) >= (bool2int(moveHereByTimestep[i-1,j,k] \/ moveHereByTimestep[i,j+1,k] \/ moveHereByTimestep[i,j,k]) - grid[(i-1)*n+j]) 
     elseif i == n /\ j == n %bottomright
        then bool2int(moveHereByTimestep[i,j,k+1]) >= (bool2int(moveHereByTimestep[i-1,j,k] \/ moveHereByTimestep[i,j-1,k] \/ moveHereByTimestep[i,j,k]) - grid[(i-1)*n+j]) 
     elseif j == n %rightmost
        then bool2int(moveHereByTimestep[i,j,k+1]) >= (bool2int(moveHereByTimestep[i-1,j,k] \/ moveHereByTimestep[i,j-1,k] \/ moveHereByTimestep[i+1,j,k] \/ moveHereByTimestep[i,j,k]) - grid[(i-1)*n+j]) 
     elseif i == n %downmost
        then bool2int(moveHereByTimestep[i,j,k+1]) >= (bool2int(moveHereByTimestep[i-1,j,k] \/ moveHereByTimestep[i,j+1,k] \/ moveHereByTimestep[i,j-1,k] \/ moveHereByTimestep[i,j,k]) - grid[(i-1)*n+j]) 
     elseif j == 1 % leftmost
        then bool2int(moveHereByTimestep[i,j,k+1]) >= (bool2int(moveHereByTimestep[i-1,j,k] \/ moveHereByTimestep[i,j+1,k] \/ moveHereByTimestep[i+1,j,k] \/ moveHereByTimestep[i,j,k]) - grid[(i-1)*n+j]) 
      elseif i == 1 %upmost
        then bool2int(moveHereByTimestep[i,j,k+1]) >= (bool2int(moveHereByTimestep[i+1,j,k] \/ moveHereByTimestep[i,j+1,k] \/ moveHereByTimestep[i,j-1,k] \/ moveHereByTimestep[i,j,k]) - grid[(i-1)*n+j]) 
     else
        bool2int(moveHereByTimestep[i,j,k+1]) >= (bool2int(moveHereByTimestep[i-1,j,k] \/ moveHereByTimestep[i+1,j,k] \/ moveHereByTimestep[i,j-1,k] \/ moveHereByTimestep[i,j+1,k] \/ moveHereByTimestep[i,j,k]) - grid[(i-1)*n+j]) 
      endif 
    )
  )
);

constraint forall(i in N) (
  forall(j in N) (
    forall(k in 1..(n*n-1)) (
     if i == 1 /\ j == 1 %topleft
        then bool2int(moveHereByTimestep[i,j,k+1]) <= (bool2int(moveHereByTimestep[i+1,j,k] \/ moveHereByTimestep[i,j+1,k] \/ moveHereByTimestep[i,j,k])) 
      elseif i == 1 /\ j == n %topright
        then bool2int(moveHereByTimestep[i,j,k+1]) <= (bool2int(moveHereByTimestep[i+1,j,k] \/ moveHereByTimestep[i,j-1,k] \/ moveHereByTimestep[i,j,k])) 
      elseif i == n /\ j == 1 %bottomleft
        then bool2int(moveHereByTimestep[i,j,k+1]) <= (bool2int(moveHereByTimestep[i-1,j,k] \/ moveHereByTimestep[i,j+1,k] \/ moveHereByTimestep[i,j,k])) 
     elseif i == n /\ j == n %bottomright
        then bool2int(moveHereByTimestep[i,j,k+1]) <= (bool2int(moveHereByTimestep[i-1,j,k] \/ moveHereByTimestep[i,j-1,k] \/ moveHereByTimestep[i,j,k])) 
     elseif j == n %rightmost
        then bool2int(moveHereByTimestep[i,j,k+1]) <= (bool2int(moveHereByTimestep[i-1,j,k] \/ moveHereByTimestep[i,j-1,k] \/ moveHereByTimestep[i+1,j,k] \/ moveHereByTimestep[i,j,k])) 
     elseif i == n %downmost
        then bool2int(moveHereByTimestep[i,j,k+1]) <= (bool2int(moveHereByTimestep[i-1,j,k] \/ moveHereByTimestep[i,j+1,k] \/ moveHereByTimestep[i,j-1,k] \/ moveHereByTimestep[i,j,k])) 
     elseif j == 1 % leftmost
        then bool2int(moveHereByTimestep[i,j,k+1]) <= (bool2int(moveHereByTimestep[i-1,j,k] \/ moveHereByTimestep[i,j+1,k] \/ moveHereByTimestep[i+1,j,k] \/ moveHereByTimestep[i,j,k])) 
      elseif i == 1 %upmost
        then bool2int(moveHereByTimestep[i,j,k+1]) <= (bool2int(moveHereByTimestep[i+1,j,k] \/ moveHereByTimestep[i,j+1,k] \/ moveHereByTimestep[i,j-1,k] \/ moveHereByTimestep[i,j,k])) 
     else
        bool2int(moveHereByTimestep[i,j,k+1]) <= (bool2int(moveHereByTimestep[i-1,j,k] \/ moveHereByTimestep[i+1,j,k] \/ moveHereByTimestep[i,j-1,k] \/ moveHereByTimestep[i,j+1,k] \/ moveHereByTimestep[i,j,k])) 
      endif 
   )
  )
);
constraint moveHereByTimestep[n,1,n*n] = 1;

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

constraint forall(k in 1..ub) (
  bool2int(moveRight[k]) + bool2int(moveUp[k]) + bool2int(moveLeft[k]) + bool2int(moveDown[k]) + bool2int(stayStill[k]) = 1
);

% ========================================================= %

% =================== Objective function ======================== %
int: goal;
constraint (ub - count([location[i] | i in 1..ub], (n*n) - n + 1) > goal);
solve satisfy;

%grid
output[if 'mod'(j,n) == 0 then show(bool2int(grid[(i-1)*n+j])) ++"\n" else show(bool2int(grid[(i-1)*n+j])) ++ " " endif | i in 1..n, j in 1..n];