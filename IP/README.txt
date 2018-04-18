Must be compiled and run with Gurobi.

Model is currently configured to Beat Objective as opposed to optimise.

To optimise, lines 81-83 should be removed from Main.java and lines 850-855 should be removed from model.java whilst line 856 should be uncommented.

Run with java Main <ModelName> size <size> ub <ub> t <timetorunfor>

Model names are "ObsWithinRange", "LimitRowsAndColumns", "PreciseObs" and "TransitiveClosure".

Note: is unlikely to terminate for grids larger than 3 x 3