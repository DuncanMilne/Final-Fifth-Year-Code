import java.util.ArrayList;

public class Node {
	ArrayList<Node> children;
	int row;
	int column;
	int obstacle;
	
	public Node(int row, int column, int obstacle) {
		this.obstacle = obstacle;
		this.row = row;
		this.column = column;
		this.children = new ArrayList<Node>();
	}
	
	Boolean checkChild(int row, int column) {
		return null;
		
	}
}
