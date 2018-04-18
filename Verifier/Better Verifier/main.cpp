#include <windows.h>
#include <vector>
#include <set>
#include <list>
#include <map>
#include <iostream>
#include <fstream>
#include <algorithm>
#include <ctime>
#include <boost/random.hpp>
#include "libtcod.hpp"

using namespace std;

#define W 13
#define H 13
typedef pair<int,int> pt;

int mx, my;

class Maze
{
public:
	bool m[W][H];
	int c[W][H+1];
	int start_x, end_x;
	int score_time, score_most, score_p;
	Maze() : start_x(0), end_x(0), score_time(0), score_most(0)
	{
		memset(m, 0, sizeof(bool)*W*H);
	}
	bool solid(int x, int y)
	{
		if (x==end_x && y==H) return false;
		if (x<0 || y<0 || x>=W || y>=H) return true;
		return m[x][y];
	}

	bool is_possible()
	{
		if (solid(start_x,0)) return false;
		bool visited[W][H+1];
		memset(visited, 0, sizeof(bool)*W*(H+1));

		list<pair<int,int> > L;
		L.push_back(pair<int,int>(start_x,0));
		while (!L.empty())
		{
			int x = L.begin()->first, y = L.begin()->second;
			L.pop_front();
			if (x==end_x && y==H) return true;
			visited[x][y]=true;
			if
				(x>0 && !visited[x-1][y] && !solid(x-1,y)) L.push_back(pair<int,int>(x-1,y));
			if (x<W-1 && !visited[x+1][y] && !solid(x+1,y)) L.push_back(pair<int,int>(x+1,y));
			if (y>0 && !visited[x][y-1] && !solid(x,y-1)) L.push_back(pair<int,int>(x,y-1));
			if (y<H && !visited[x][y+1] && !solid(x,y+1)) L.push_back(pair<int,int>(x,y+1));			
		}
		return false;
	}
	void compute_score()
	{
		int x = start_x, y=0;
		memset(c, 0, sizeof(int)*W*(H+1));
		score_time = 1;
		for (;!(x==end_x && y==H);)
		{
			++score_time;
			++c[x][y];
//down, right, left, up
			if (!solid(x,y+1) && (solid(x-1,y) || c[x][y+1]<=c[x-1][y]) && (solid(x,y-1) || c[x][y+1]<=c[x][y-1]) && (solid(x+1,y) || c[x][y+1]<=c[x+1][y]))
				++y;
			else if (!solid(x+1,y) && (solid(x-1,y) || c[x+1][y]<=c[x-1][y]) && (solid(x,y-1) || c[x+1][y]<=c[x][y-1]))
				++x;
			else if (!solid(x-1,y) && (solid(x,y-1) || c[x-1][y]<=c[x][y-1]))
				--x;
			else
				--y;
		}
		score_most = 0;
		for (int i=0; i<W; ++i)
			for (int j=0; j<H; ++j)
				score_most = max(score_most, c[i][j]);
		score_p = c[mx][my];
	}
	void optimise_start_x() //compute score for each start x, find optimal
	{
		int best_t=-1, best_v=-1, best_x1=-1, best_x2=-1;
		for (int i=0; i<W; ++i)
		{
			start_x=i;
			for (int j=0; j<W; ++j)
			{
				end_x = j;
				if (is_possible())
				{
					compute_score();
					if (score_time >= best_t && score_most >= best_v)
					{
						best_v = score_most;
						best_t = score_time;
						best_x1 = i;
						best_x2 = j;
					}
				}
			}
		}
		score_most = best_v;
		score_time = best_t;
		start_x = best_x1;
		end_x = best_x2;
	}
	void save()
	{
		ofstream f;
		f.open("maze.txt");
		if (is_possible())
		{
			compute_score();
			f << score_time << " / " << score_most <<endl;
		}
		for (int j=0; j<W; ++j)
			if (j==start_x) f << "v";
			else f << " ";
		f << endl;

		for (int i=0; i<H; ++i)
		{
			for (int j=0; j<W; ++j)
				if (m[j][i]==0) f << ".";
				else f << "#";
			f << endl;
		}

		for (int j=0; j<W; ++j)
			if (j==end_x) f << "^";
			else f << " ";
		f.close();
	}
};

boost::mt19937 mt2;
boost::uniform_int<> intm(0,INT_MAX);
boost::variate_generator<boost::mt19937, boost::uniform_int<> > rng2(mt2, intm);

int drnd(int m)
{
	if (m==0) return 0;
	return rng2()%m;
}

int rnd(int m)
{
	if (m==0) return 0;
	return rng2()%m;
}
	
Maze *get_random_maze()
{
	Maze *m = new Maze();
	do
	{
		for (int i=0; i<W; ++i)
			for (int j=0; j<H; ++j)
			{
				m->m[i][j] = (rnd(2)==0);
			}
		m->optimise_start_x();
	}
	while (!m->is_possible());
	return m;
}

Maze *maze;

void change_best()
{
	int bx=-1, by=-1, bt=0;
	for (int i=0; i<W; ++i)
		for (int j=0; j<H; ++j)
		{
			maze->m[i][j] = !maze->m[i][j];
			if (maze->is_possible())
			{
				maze->compute_score();
				if (maze->score_time > bt)
				{
					bx = i;
					by = j;
					bt = maze->score_time;
				}
			}
			maze->m[i][j] = !maze->m[i][j];
		}
	maze->m[bx][by] = !maze->m[bx][by];
}

void read_input()
{
	TCOD_key_t key=TCODConsole::waitForKeypress(true);
	switch(key.vk)
	{
	case TCODK_CHAR:
		switch (key.c)
		{
		case 'h':
			mx = max(0,mx-1); break;
		case 'j':
			my = min(H-1,my+1); break;
		case 'k':
			my = max(0,my-1); break;
		case 'l':
			mx = min(W-1,mx+1); break;
		case 'q':
			maze->start_x= max(0,maze->start_x-1); break;
		case 'w':
			maze->start_x= min(W-1,maze->start_x+1); break;
		case 'a':
			maze->end_x= max(0,maze->end_x-1); break;
		case 's':
			maze->end_x= min(W-1,maze->end_x+1); break;
		case 'z':
			maze->save(); break;
		case 'r':
			delete maze;  maze = get_random_maze(); break;
		case 'c':
			{for (int i=0; i<W; ++i) for (int j=0; j<H; ++j) maze->m[i][j]=false;} break;
		case 't':
			change_best(); break;
		default:
			break;
		}
		break;
	case TCODK_SPACE:
		maze->m[mx][my] = !maze->m[mx][my]; break;
	case TCODK_ESCAPE:
		exit(0);
	default:
		break;
	}
}

char ch(bool b)
{
	if (b) return '#';
	else return '.';
}

void draw()
{
	for (int i=0; i<H+2; ++i)
		for (int j=0; j<W+20; ++j)
			TCODConsole::root->putChar(j,i,' ');

	TCODConsole::root->setForegroundColor(TCODColor::white);
	if (maze->is_possible())
	{
		maze->compute_score();
		TCODConsole::root->printLeft(W+1, 1, TCOD_BKGND_NONE, "moves: %d", maze->score_time);
		TCODConsole::root->printLeft(W+1, 2, TCOD_BKGND_NONE, "visits: %d", maze->score_most);
		TCODConsole::root->printLeft(W+1, 3, TCOD_BKGND_NONE, "cursor visits: %d", maze->score_p);
	}
	else
		TCODConsole::root->printLeft(W+1, 1, TCOD_BKGND_NONE, "impossible");

	for (int i=0; i<H; ++i)
		for (int j=0; j<W; ++j)
		{
			if (i==my && j==mx) TCODConsole::root->setForegroundColor(TCODColor::white);
			else TCODConsole::root->setForegroundColor(TCODColor::grey);
			TCODConsole::root->setBackgroundColor(TCODColor(maze->c[j][i],maze->c[j][i],maze->c[j][i]));
			TCODConsole::root->putChar(j,i+1,ch(maze->m[j][i]));
		}
	TCODConsole::root->setBackgroundColor(TCODColor::black);
	TCODConsole::root->setForegroundColor(TCODColor::grey);
	TCODConsole::root->putChar(maze->start_x,0,'v');
	TCODConsole::root->putChar(maze->end_x,H+1,'^');

	TCODConsole::root->setForegroundColor(TCODColor::grey);
	TCODConsole::root->printLeft(W+1, 5, TCOD_BKGND_NONE, "hjkl - move cursor");
	TCODConsole::root->printLeft(W+1, 6, TCOD_BKGND_NONE, "space - change tile");
	TCODConsole::root->printLeft(W+1, 7, TCOD_BKGND_NONE, "qw - move start");
	TCODConsole::root->printLeft(W+1, 8, TCOD_BKGND_NONE, "as - move end");
	TCODConsole::root->printLeft(W+1, 9, TCOD_BKGND_NONE, "z - save maze.txt");
	TCODConsole::root->printLeft(W+1, 10, TCOD_BKGND_NONE, "c - clear");
	TCODConsole::root->printLeft(W+1, 11, TCOD_BKGND_NONE, "r - new random maze");
	TCODConsole::root->printLeft(W+1, 12, TCOD_BKGND_NONE, "t - change 1 tile");

	TCODConsole::flush();
}

int APIENTRY WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	maze = get_random_maze();

	mt2.seed((unsigned int)time(0));
	rng2 = boost::variate_generator<boost::mt19937, boost::uniform_int<> >(mt2, intm);

	TCODConsole::setCustomFont("terminal4.png",TCOD_FONT_LAYOUT_ASCII_INCOL,16,16);
	TCODConsole::initRoot(W+20,H+2,"Mousemaze",false);

	for (;;)
	{
		
		draw();
		read_input();
	}
}
