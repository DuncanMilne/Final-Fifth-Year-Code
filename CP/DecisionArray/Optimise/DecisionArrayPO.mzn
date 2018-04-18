include "globals.mzn";

int: n;
set of int: N = 1..n;
int: ub;
set of int: UB = 1..ub; % set of ints from 1 to the upper bound

% ================= GRID CONSTRAINTS  ==================== %
array[1..n*n] of var bool: grid;

constraint grid[1] = false;
constraint grid[(n*n)-n+1] = false;
constraint sum([grid[(i*n)-n+1]  | i in 2..(n-1)]) > 0;
% must be leq than n*n - n obs. in a 3x3 any grid with more than 6 obstacles is impossible
constraint sum([grid[i]  | i in 2..(n*n)]) <= (n*n)-n;

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
array[N, N, 1..ub] of var 0..ub: visits;
array[N, N, 1..ub] of var bool: decisions;
constraint forall(i in N) (
  forall(j in N) (
    if i == 1 /\ j == 1
      then decisions[i,j,1] = true
    else
      decisions[i,j,1] = false
    endif
  )
);

%counts visits
constraint forall(i in N) (
  forall(j in N) (
    forall(k in 1..ub) (
      visits[i,j,k] = sum([bool2int(decisions[i,j,l]) | l in 1..k]) + (bool2int(grid[((i-1)*n)+j]) * (ub))
    )
  )
);

%one move per timestep 
%THIS IS A NECESSARY CONSTRAINT
constraint forall(k in 1..ub) (
  sum([bool2int(decisions[i,j,k]) | i in 1..n, j in 1..n]) = 1
);
%all decisions leq 1 - if moving to end cell
constraint forall(k in 1..ub) (
  forall(i in 1..n) (
    forall(j in 1..n) (
      if i==n /\ j == 1 then
        decisions[i,j,k] = decisions[i,j,k]
      else
        decisions[i,j,k] <= 1 - decisions[n,1,k]
      endif
    )
  )
);

% ============================================================= %

% =============== MOVEMENT CONSTRAINT DOWN ================== %
constraint forall(i in 1..(n-1)) (
  forall(j in N) (
    forall(k in 1..(ub-1)) (
      if i == 1 /\ j == 1 %topleft
        then decisions[i+1,j,k+1] >=  (decisions[i,j,k] /\ (visits[i+1,j,k] <= visits[i,j+1,k]))
      elseif i == 1 /\ j == n %topright
        then decisions[i+1,j,k+1] >=  (decisions[i,j,k] /\ (visits[i+1,j,k] <= visits[i,j-1,k]))
     elseif  j == n % when rightmost
        then decisions[i+1,j,k+1] >=  (decisions[i,j,k] /\ (visits[i+1,j,k] <= visits[i,j-1,k]) /\ visits[i+1,j,k] <= visits[i-1,j,k])
     elseif j == 1 % when leftmost
       then decisions[i+1,j,k+1] >=  (decisions[i,j,k] /\ (visits[i+1,j,k] <= visits[i,j+1,k]) /\ visits[i+1,j,k] <= visits[i-1,j,k])
     elseif i == 1 %when topmost
        then decisions[i+1,j,k+1] >=  (decisions[i,j,k] /\ (visits[i+1,j,k] <= visits[i,j+1,k]) /\ (visits[i+1,j,k] <= visits[i,j-1,k]))
      else
        decisions[i+1,j,k+1] >=  (decisions[i,j,k] /\ (visits[i+1,j,k] <= visits[i,j+1,k]) /\ (visits[i+1,j,k] <= visits[i,j-1,k]) /\ (visits[i+1,j,k] <= visits[i-1,j,k]))
      endif 
    )
  )
);
  
% =============== MOVEMENT CONSTRAINT RIGHT ================== %
constraint forall(i in N) (
  forall(j in 1..n-1) (
    forall(k in 1..(ub-1)) (
      if i == 1 /\ j == 1 %topleft
        then decisions[i,j+1,k+1] >=  (decisions[i,j,k] /\ (visits[i,j+1,k] < visits[i+1,j,k]))
      elseif i == n /\ j == 1 %bottomleft
        then decisions[i,j,k+1] >=  decisions[i,j,k]
     elseif  i == n % when downmost
        then decisions[i,j+1,k+1] >=  (decisions[i,j,k] /\ (visits[i,j+1,k] <= visits[i,j-1,k]) /\ visits[i,j+1,k] <= visits[i-1,j,k])
     elseif j == 1 % when leftmost
       then decisions[i,j+1,k+1] >=  (decisions[i,j,k] /\ (visits[i,j+1,k] <= visits[i-1,j,k]) /\ visits[i,j+1,k] < visits[i+1,j,k])
     elseif i == 1 %when topmost
        then decisions[i,j+1,k+1] >=  (decisions[i,j,k] /\ (visits[i,j+1,k] <= visits[i,j-1,k]) /\ (visits[i,j+1,k] < visits[i+1,j,k]))
      else
        decisions[i,j+1,k+1] >=  (decisions[i,j,k] /\ (visits[i,j+1,k] < visits[i+1,j,k]) /\ (visits[i,j+1,k] <= visits[i,j-1,k]) /\ (visits[i,j+1,k] <= visits[i-1,j,k]))
      endif 
    )
  )
);

% =============== MOVEMENT CONSTRAINTS LEFT ================== %
constraint forall(i in N) (
  forall(j in 2..n) (
    forall(k in 1..(ub-1)) (
      if i == 1 /\ j == n %topright
        then decisions[i,j-1,k+1] >=  (decisions[i,j,k] /\ (visits[i,j-1,k] < visits[i+1,j,k]))
      elseif i == n /\ j == n %bottomright
        then decisions[i,j-1,k+1] >=  (decisions[i,j,k] /\ (visits[i,j-1,k] <= visits[i-1,j,k]))
     elseif  j == n % when rightmost
        then decisions[i,j-1,k+1] >=  (decisions[i,j,k] /\ (visits[i,j-1,k] < visits[i+1,j,k]) /\ visits[i,j-1,k] <= visits[i-1,j,k])
     elseif i == n % when downmost
       then decisions[i,j-1,k+1] >=  (decisions[i,j,k] /\ (visits[i,j-1,k] < visits[i,j+1,k]) /\ visits[i,j-1,k] <= visits[i-1,j,k])
     elseif i == 1 %when topmost
        then decisions[i,j-1,k+1] >=  (decisions[i,j,k] /\ (visits[i,j-1,k] < visits[i+1,j,k]) /\ (visits[i,j-1,k] < visits[i,j+1,k]))
      else
        decisions[i,j-1,k+1] >=  (decisions[i,j,k] /\ (visits[i,j-1,k] < visits[i+1,j,k]) /\ (visits[i,j-1,k] < visits[i,j+1,k]) /\ (visits[i,j-1,k] <= visits[i-1,j,k]))
      endif 
    )
  )
);

% =============== MOVEMENT CONSTRAINTS UP ==================== %
constraint forall(i in 2..n) (
  forall(j in N) (
    forall(k in 1..(ub-1)) (
      if i == n /\ j == 1 %bottomleft
        then decisions[i,j,k+1] >=  decisions[i,j,k]
      elseif i == n /\ j == n %bottomright
        then decisions[i-1,j,k+1] >=  (decisions[i,j,k] /\ (visits[i-1,j,k] < visits[i,j-1,k]))
     elseif  j == n % when rightmost
        then decisions[i-1,j,k+1] >=  (decisions[i,j,k] /\ (visits[i-1,j,k] < visits[i+1,j,k]) /\ visits[i-1,j,k] < visits[i,j-1,k])
     elseif i == n % when downmost
       then decisions[i-1,j,k+1] >=  (decisions[i,j,k] /\ (visits[i-1,j,k] < visits[i,j+1,k]) /\ visits[i-1,j,k] < visits[i,j-1,k])
     elseif j == 1 %when leftmost
        then decisions[i-1,j,k+1] >=  (decisions[i,j,k] /\ (visits[i-1,j,k] < visits[i+1,j,k]) /\ (visits[i-1,j,k] < visits[i,j+1,k]))
      else
        decisions[i-1,j,k+1] >=  (decisions[i,j,k] /\ (visits[i-1,j,k] < visits[i+1,j,k]) /\ (visits[i-1,j,k] < visits[i,j+1,k]) /\ (visits[i-1,j,k] < visits[i,j-1,k]))
      endif 
    )
  )
);

solve minimize(visits[n,1,ub]);

%grid
output[if 'mod'(j,n) == 0 then show(bool2int(grid[(i-1)*n+j])) ++"\n" else show(bool2int(grid[(i-1)*n+j])) ++ " " endif | i in 1..n, j in 1..n];
