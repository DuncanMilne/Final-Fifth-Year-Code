public class HammingDistanceMaze {

	private boolean[] maze;
	private Integer[] visits;
	Location<Integer, Integer> location;

	public HammingDistanceMaze(boolean[] maze) {
	}

	void printMaze() {
		for (int i = 0; i < 13; i++) {
			for (int j = 0; j < 13; j++) {
				if (maze[i * 13 + j])
					System.out.print(1 + ",");
				else
					System.out.print(0 + ",");
			}
			System.out.println();
		}
	}

	// Creates 2d array of same size as maze but places 0 in all cells
	void createVisits2DArray(boolean[] maze) {
		this.maze = maze;
		visits = new Integer[169];
		for (int i = 0; i < 169; i++) {
			if (maze[i])
				visits[i] = Integer.MAX_VALUE;
			else
				visits[i] = 0;
		}
		visits[0] = 1;
	}

	// returns true if x has <= y's visits, false otherwise
	public boolean compareLocations(Location<Integer, Integer> x, Location<Integer, Integer> y) {
		if (visits[((x.row - 1) * 13) + x.column - 1] <= visits[((y.row - 1) * 13) + y.column - 1])
			return true;
		else
			return false;
	}

	public Location<Integer, Integer> nextCell(Location<Integer, Integer> location) {

		// handle edge cases here then say else compare all adjacent squares
		if (location.row == 13 && location.column == 13) { // if bottom right dont look right or down
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
		} else if (location.row == 1 && location.column == 13) { // if top right dont look right or up
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

		} else if (location.column == 13) { // dont look right
			Location<Integer, Integer> down = new Location<Integer, Integer>(location.row + 1, location.column);
			Location<Integer, Integer> left = new Location<Integer, Integer>(location.row, location.column - 1);
			Location<Integer, Integer> up = new Location<Integer, Integer>(location.row - 1, location.column);

			if (compareLocations(down, left) && compareLocations(down, up))
				return down;
			else if (compareLocations(left, up))
				return left;
			else
				return up;
		} else if (location.row == 13) { // dont look down
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

	public int simulateMouseMaze() {

		Location<Integer, Integer> location = new Location<Integer, Integer>(1, 1); // this is the start cell

		int steps = 2;
		// Checks to see if mouse is in finish cell
		while (location.row != 13 || location.column != 1) { // while not at finish square
			if (steps > 50000) {
				return -1;
			}
			location = nextCell(location);
			visits[((location.row - 1) * 13) + location.column - 1]++;
			steps++;
		}

		return steps;
	}

}
