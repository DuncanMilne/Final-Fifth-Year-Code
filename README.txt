Running MiniZinc files is done with the following command:

mzn-gecode <filename.mzn> -D"n=<size>;ub=<upper bound>;goal=<goal, not required if optimising>;obs=<only require with precise obs>;" -s

Note: include -a in above command to print all results

Running the Gurobi implementation, the brute force implementation, the Hamming Distance implementation and the verifier are all described in the corresponding folder's readme.

For any queries please contact duncan.milne1@gmail.com