import java.util.ArrayList;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class MaxStepsPreciseObs {

	int highscore = 0;
	static int[][] maze;
	static int[][] deepCopiedMaze; // stores current best answer

	static ArrayList<ArrayList<Node>> allNodes = new ArrayList<ArrayList<Node>>();
	private static ArrayList<ArrayList<Integer>> visits; // stores number of visits to each cell for current
															// configuration of maze

	static ArrayList<Node> visited = new ArrayList<Node>();
	static int maxMoves = 0; // stores best score so far
	static long millis1;
	private static int n; // size of maze
	private static long processed = 0;
	static int obs = 0;
	static int goalObs;
	static int maxSteps;
	static long end;

	public static void main(String[] args) {
		n = Integer.parseInt(args[0]);
		maze = new int[n][n];

		goalObs = Integer.parseInt(args[1]);

		maxSteps = Integer.parseInt(args[2]);

		millis1 = System.currentTimeMillis();
		choose(1, 1);

		System.out.println("best score " + maxMoves);
		// print out the maze
		for (int[] row : deepCopiedMaze) {
			for (int value : row) {
				System.out.print(value);
			}
			System.out.println();
		}
		System.out.println("took " + (System.currentTimeMillis() - millis1) + " milliseconds");
	}

	static void choose(int i, int j) { // i is x coord j is y coord
		if (i > n) {
			processed++;
			if (processed % 5000000 == 0) {
				long millis2 = System.currentTimeMillis();
				System.out.println(
						"runtime " + (millis2 - millis1) / 1000 + "." + (millis2 - millis1) % 1000 + " seconds");
				System.out.println(((double) processed / ((long) Math.pow(2, (n * n - 2)))) * 100 + "% processed");
			}
			if (obs == goalObs) {
				createVisits2DArray(); // sets all values in visits to be 0
				int moves = simulateMouseMaze(); // counts number of moves and stores it in moves
				if (moves >= maxMoves) {
					System.out.println("current best moves " + moves);
					for (int row = 0; row < n; row++) {
						for (int val = 0; val < n; val++) {
							System.out.print(maze[row][val] + " ");
						}
						System.out.println();
					}
					maxMoves = moves;
					deepCopiedMaze = new int[n][n];
					for (int row = 0; row < n; row++) {
						for (int val = 0; val < n; val++) {
							deepCopiedMaze[row][val] = maze[row][val];
						}
					}
				}
			}
		} else {
			maze[i - 1][j - 1] = 0;
			choose(i + (j / n), j % n + 1); // for current cell, try every combination of every other cell when
											// current cell does not have obstacle
			if (!(i == 1 && j == 1) && !(i == n && j == 1)) { // if not at start cell or finish cell
				maze[i - 1][j - 1] = 1;
				obs++;
				choose(i + (j / n), j % n + 1);
				obs--;
			}
		}
	}

	static void addChildren(Node node) {
		try {
			if (allNodes.get(node.row - 1).get(node.column).obstacle == 0) {
				node.children.add(allNodes.get(node.row - 1).get(node.column));
			}
		} catch (Exception e) {
		}
		try {
			if (allNodes.get(node.row + 1).get(node.column).obstacle == 0) {
				node.children.add(allNodes.get(node.row + 1).get(node.column));
			}
		} catch (Exception e) {

		}
		try {
			if (allNodes.get(node.row).get(node.column - 1).obstacle == 0) {
				node.children.add(allNodes.get(node.row).get(node.column - 1));
			}
		} catch (Exception e) {
		}
		try {
			if (allNodes.get(node.row).get(node.column + 1).obstacle == 0) {
				node.children.add(allNodes.get(node.row).get(node.column + 1));
			}

		} catch (Exception e) {
		}
	}

	public static int simulateMouseMaze() {

		Location<Integer, Integer> location = new Location<Integer, Integer>(1, 1); // this is the start cell

		int newVisitsValue = 0;

		int steps = 2;
		// Checks to see if mouse is in finish cell
		while (location.row != n || location.column != 1) { // while not at finish square
			if (steps > maxSteps) {
				return -1;
			}
			location = nextCell(location);
			newVisitsValue = visits.get(location.row - 1).get(location.column - 1) + 1;
			visits.get(location.row - 1).set(location.column - 1, newVisitsValue);
			steps++;
		}

		return steps;
	}

	public static Location<Integer, Integer> nextCell(Location<Integer, Integer> location) {

		// handle edge cases here then say else compare all adjacent squares
		if (location.row == n && location.column == n) { // if bottom right dont look right or down
			Location<Integer, Integer> left = new Location<Integer, Integer>(location.row, location.column - 1);
			Location<Integer, Integer> up = new Location<Integer, Integer>(location.row - 1, location.column);

			if (compareLocations(left, up)) {
				return left;
			} else {
				return up;
			}
		} else if (location.row == 1 && location.column == 1) { // if top left dont look left or up
			Location<Integer, Integer> down = new Location<Integer, Integer>(location.row + 1, location.column);
			Location<Integer, Integer> right = new Location<Integer, Integer>(location.row, location.column + 1);

			if (compareLocations(down, right)) {
				return down;
			} else {
				return right;
			}
		} else if (location.row == 1 && location.column == n) { // if top right dont look right or up
			Location<Integer, Integer> down = new Location<Integer, Integer>(location.row + 1, location.column);
			Location<Integer, Integer> left = new Location<Integer, Integer>(location.row, location.column - 1);

			if (compareLocations(down, left)) {
				return down;
			} else {
				return left;
			}
		} else if (location.column == 1) { // leftmost column dont look left
			Location<Integer, Integer> down = new Location<Integer, Integer>(location.row + 1, location.column);
			Location<Integer, Integer> right = new Location<Integer, Integer>(location.row, location.column + 1);
			Location<Integer, Integer> up = new Location<Integer, Integer>(location.row - 1, location.column);

			if (compareLocations(down, right) && compareLocations(down, up))
				return down;
			else if (compareLocations(right, up))
				return right;
			else
				return up;

		} else if (location.column == n) { // dont look right
			Location<Integer, Integer> down = new Location<Integer, Integer>(location.row + 1, location.column);
			Location<Integer, Integer> left = new Location<Integer, Integer>(location.row, location.column - 1);
			Location<Integer, Integer> up = new Location<Integer, Integer>(location.row - 1, location.column);

			if (compareLocations(down, left) && compareLocations(down, up))
				return down;
			else if (compareLocations(left, up))
				return left;
			else
				return up;
		} else if (location.row == n) { // dont look down
			Location<Integer, Integer> right = new Location<Integer, Integer>(location.row, location.column + 1);
			Location<Integer, Integer> left = new Location<Integer, Integer>(location.row, location.column - 1);
			Location<Integer, Integer> up = new Location<Integer, Integer>(location.row - 1, location.column);

			if (compareLocations(right, left) && compareLocations(right, up))
				return right;
			else if (compareLocations(left, up))
				return left;
			else
				return up;
		} else if (location.row == 1) { // dont look up
			Location<Integer, Integer> down = new Location<Integer, Integer>(location.row + 1, location.column);
			Location<Integer, Integer> right = new Location<Integer, Integer>(location.row, location.column + 1);
			Location<Integer, Integer> left = new Location<Integer, Integer>(location.row, location.column - 1);

			if (compareLocations(down, right) && compareLocations(down, left))
				return down;
			else if (compareLocations(right, left))
				return right;
			else
				return left;

		} else { // else compare all since we wont be in this method if the mouse is bottom left
					// anyway
			Location<Integer, Integer> down = new Location<Integer, Integer>(location.row + 1, location.column);
			Location<Integer, Integer> right = new Location<Integer, Integer>(location.row, location.column + 1);
			Location<Integer, Integer> left = new Location<Integer, Integer>(location.row, location.column - 1);
			Location<Integer, Integer> up = new Location<Integer, Integer>(location.row - 1, location.column);

			if (compareLocations(down, right) && compareLocations(down, left) && compareLocations(down, up))
				return down;
			else if (compareLocations(right, left) && compareLocations(right, up))
				return right;
			else if (compareLocations(left, up))
				return left;
			else
				return up;
		}

	}

	// returns true if x has <= y's visits, false otherwise
	public static boolean compareLocations(Location<Integer, Integer> x, Location<Integer, Integer> y) {
		if (visits.get(x.row - 1).get(x.column - 1) <= visits.get(y.row - 1).get(y.column - 1))
			return true;
		else
			return false;
	}

	// Creates 2d array of same size as maze but places 0 in all cells
	private static void createVisits2DArray() {

		visits = new ArrayList<ArrayList<Integer>>();

		for (int i = 0; i < n; i++) {
			visits.add(new ArrayList<Integer>());
			for (int value : maze[i]) {
				if (value == 0)
					visits.get(i).add(0);
				else
					visits.get(i).add(Integer.MAX_VALUE);
			}
		}

		// Squeaky starts by moving to the start square. Easier to simply start this
		// value at 1 than to factor in additional vertices with different movement
		// conditions.
		visits.get(0).set(0, 1);
	}

}
