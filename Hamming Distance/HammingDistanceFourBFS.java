
public class HammingDistanceFourBFS {

	static boolean[] maze = { false, true, false, true, true, true, true, true, false, true, false, true, true, false,
			false, false, true, false, true, false, true, false, false, false, false, true, false, true, false, false,
			false, false, true, false, false, true, false, true, false, false, false, true, true, false, true, false,
			true, false, true, false, false, false, false, true, true, false, false, true, false, false, false, false,
			true, false, true, false, false, false, true, false, false, false, false, false, true, false, false, false,
			false, false, false, true, false, true, false, true, true, false, true, false, true, false, true, false,
			false, true, false, true, false, true, true, false, false, true, false, false, false, true, false, false,
			false, false, false, false, true, false, false, true, true, true, false, true, false, true, true, false,
			true, true, false, true, false, false, false, false, true, false, true, false, false, false, false, false,
			false, false, true, false, false, false, false, false, true, false, true, true, false, true, false, true,
			false, true, false, true, true, false, false, false, true, true, true };

	public static void main(String[] args) {
		long millis1 = System.currentTimeMillis();
		HammingDistanceBFSMaze mazeObject = new HammingDistanceBFSMaze(maze);
		int steps, processed = 0;
		for (int i = 1; i < 166; i++) {
			maze[i] = !maze[i];
			for (int j = i + 1; j < 167; j++) {
				maze[j] = !maze[j];
				for (int k = j + 1; k < 168; k++) {
					maze[k] = !maze[k];
					for (int l = k + 1; l < 169; l++) {
						maze[l] = !maze[l];
						mazeObject.createVisits2DArray(maze);
						steps = mazeObject.simulateMouseMaze();
						if (steps > 35500) {
							mazeObject.printMaze();
							System.out.println(steps);
						}
						processed++;
						if (processed % 50000 == 0) {
							System.out.println((double) processed / 32795126 * 100 + "% processed");
							long millis2 = System.currentTimeMillis();
							System.out.println("runtime " + (millis2 - millis1) / 1000 + "."
									+ (millis2 - millis1) % 1000 + " seconds");

						}
						maze[l] = !maze[l];
					}
					maze[k] = !maze[k];
				}
				maze[j] = !maze[j];
			}
			maze[i] = !maze[i];
		}
	}

}
