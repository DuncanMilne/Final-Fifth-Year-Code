Solutions are currently set to print all solutions found that score as high as the incumbent solution or higher

Changing the solution to only print higher scoring solutions is left as an exercise for the interested reader.

Only joking, see http://drops.dagstuhl.de/opus/volltexte/2016/5874/pdf/14.pdf if confused.

Change line 54 in BFSFeasibility.java to simply greater than to make this change.

Corresponding line in BFSFeasibilityPreciseObs.java is line number 56

MaxSteps.java corresponding line is 45.

MaxStepsPreciseObs.java corresponding line is 

Crashes will occur if no maze was deep copied.

Examples for running the four implementations are as follows, where <size of maze> being 3 would evaluate a 3x3 grid:

java BFSFeasibility <size of maze>

java BFSFeasibilityPreciseObs <size of maze> <number of obs>

java MaxSteps <size of maze> <upper bound>

java MaxStepsPreciseObs <size of maze> <number of obs> <upper bound>