import java.awt.Toolkit;

import gurobi.GRB;
import gurobi.GRBCallback;
import gurobi.GRBException;
import gurobi.GRBLinExpr;

public class Main extends GRBCallback {

	static Model model;

	static int size = -1;
	
	public static void main(String[] args) {

		if (args.length == 0) {
			System.out.println("Please re-run with a correct set of arguments.");
			listCommands();
			System.exit(1);
		}

		int score = -1;
		int timeInMinutes = -1;
		String fileToPrintTo = "";
		String arg;
		int obs = -1;
		int upperBound = -1;
		for (int i = 1; i < args.length; i += 2) {
			arg = args[i];
			switch (arg) {
			case "h":
				listCommands();
				i--; // Have placed this here as it is the only command where we do not want to
						// increment i by 2.
				break;
			case "size":
				try {
					size = Integer.parseInt(args[i + 1]);
				} catch (NumberFormatException e) {
					System.out.println("The value after 'size' must be an integer! Run with the flag 'h' for help.");
				}
				break;
			case "score":
				try {
					score = Integer.parseInt(args[i + 1]);
				} catch (NumberFormatException e) {
					System.out.println("The value after 'score' must be an integer! Run with the flag 'h' for help.");
				}
				break;
			case "t":
				try {
					timeInMinutes = Integer.parseInt(args[i + 1]);
				} catch (NumberFormatException e) {
					System.out.println("The value after 't' must be an integer! Run with the flag 'h' for help.");
				}
				break;
			case "ub":
				upperBound = Integer.parseInt(args[i + 1]);
				break;
			default:
				System.out.println("Invalid flag " + arg);
			}
		}

		// If user doesn't set size set it as 1
		if (size == -1) {
			size = 1;
		}
		model = new Model(args[0], size, score, upperBound, obs);

		try {
			if (timeInMinutes!=-1)
				model.GRBModel.set(GRB.DoubleParam.TimeLimit, timeInMinutes/60);
			
			// Print grid every time incumbent solution is improved upon
			model.GRBModel.setCallback(new Main());
			
			// fake expr is used so gurobi simply looks for feasible solutions as Gurobi is required to optimise.
			// If the desire is to optimise, remove fakeExpr from the model and change the objective in the Model file to the line commented out in the setObjectiveFunction() method
			long millis1 = System.currentTimeMillis();
			GRBLinExpr fakeExpr = new GRBLinExpr();
			fakeExpr.addConstant(1);
			model.GRBModel.setObjective(fakeExpr);
			model.GRBModel.optimize();
			long millis2 = System.currentTimeMillis();
			
			int status = model.GRBModel.get(GRB.IntAttr.Status);
			
			if (status == GRB.Status.INFEASIBLE) {
				System.out.println("no solution found in the following instance, status was: " + status);
			} else if (status == 9) {
				model.utilities.printGrid(model.grid);
				System.out.println("t is " + (int) model.objective.getValue());
			} else {
				model.utilities.printGrid(model.grid);
				System.out.println("t is " + ((int) model.objective.getValue()));
				System.out
						.println("took " + (millis2 - millis1) / 1000 + "." + (millis2 - millis1) % 1000 + " seconds");
				// If Squeaky didn't manage to reach the finish cell
				if (model.decisions.get(size - 1).get(0).get((int) model.upperBound - 1).get(GRB.DoubleAttr.X) != 1) { 
					System.out.println("UPPERBOUND NOT LARGE ENOUGH");
				}
			}
			model.GRBModel.dispose();
			model.GRBEnv.dispose();
		} catch (GRBException e) {
			e.printStackTrace();
		}
	}

	private static void listCommands() {
		System.out.println("You can use the following flags when running Main.java");
		System.out.println("'h - lists all commands");
		System.out.println("'size - takes 1 integer as a parameter representing the size of the rows and columns");
		System.out.println(
				"'score - Takes 1 parameter representing the score the solver is aiming to beat. If this flag is not included the solver will solve for the optimal solution");
		System.out.println(
				"'ub - Takes 1 parameter representing the upper bound on the number of moves Squeaky can make");
		System.out.println(
				"'t - Takes 1 parameter specifying the time in minutes that the solver is to run for before termininating and giving the best score found thus far.");
	}

	// Print grid out when new incumbent is found
	@Override
	protected void callback() {
		if (this.where == 4) {
			try {
				for (int i = 0; i < size; i++) {
					for (int j = 0; j < size; j++) {
						System.out.print(this.getSolution(model.grid.get(i).get(j)) + " ");
					}
					System.out.println();
				}
			} catch (GRBException e) {
				e.printStackTrace();
			}
		}
	}
}
