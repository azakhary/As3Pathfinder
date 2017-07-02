/*

 Pathfinder 1.2 or as3pathfinder is a Grid Pathfinding Library that is findig shortest route
 from start point to end on a 2D grid for given map of obstacles.

 targeted for the Flash player platform

 http://code.google.com/p/pathfinder/

 Copyright (c) 2010 - 3000 Avetis Zakharyan, All Rights Reserved.

 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.

 */
package utils.pathfind {

import flash.geom.Point;

public class AStarPathfinder {

	/**
	 * Two Dimensional Array/Vector Containing Obstacle Map marked with 1 or 0 values where 1 is obstacle
	 */
	private var map:Array;

	/**
	 * Flag to identify if diagonal movement is allowed on the map
	 */
	private var canGoDiagonal:Boolean;

//	/**
//	 * Temporary Array to keep array of previously visited point durring path calculation
//	 */
//	private var previousPoints:Array;

	/**
	 * Map X Dimension
	 */
	private var columnCount:Number;

	/**
	 * Map Y Dimension
	 */
	private var rowCount:Number;

	/**
	 * ???
	 */
	private var useRealisticPath:Boolean = false;


	/**
	 * remove middle points in straight line.
	 */
	private var useCompressedPath:Boolean = true;

	/**
	 * Empty Constructor (Nothing to do here)
	 */
	public function AStarPathfinder(useRealisticPath:Boolean = false, canGoDiagonal:Boolean = false, useCompressedPath:Boolean = true) {
		this.useRealisticPath = useRealisticPath;
		this.canGoDiagonal = canGoDiagonal;
		this.useCompressedPath = useCompressedPath;
	}

	/**
	 * Loads obstacle map before doing path calculations
	 * Obstacle map is a two Dimensional Array Containing 1 or 0 values where 1 is obstacle
	 * Also please provide map dimensions
	 */
	public function loadMap(map:Array, columnCount:int, rowCount:int, dataName:String):void {
		this.map = map;
		this.columnCount = columnCount;
		this.rowCount = rowCount;
	}

	/**
	 * Returns Array of path points for given start and end points,
	 * pass diag = false if diagonal movements are not allowed on the map
	 */
	public function getPath(startPoint:Point, endPoint:Point, doIncludeEnds:Boolean = true):Array {
		var retVal:Array = new Array();

		var tmpMap:Array = [];
		for (var i:Number = 0; i < columnCount; i++) {
			if (tmpMap[i] == null) {
				tmpMap[i] = new Array();
			}
			for (var j:Number = 0; j < rowCount; j++) {
				tmpMap[i][j] = 0;
			}
		}

		tmpMap[startPoint.x][startPoint.y] = 1;
		tmpMap[endPoint.x][endPoint.y] = -1;

		var previousPoints:Array = new Array;
		previousPoints.push(startPoint);

		var iterationsCount:Number = iterate(tmpMap, previousPoints);

		retVal = getPathArray(tmpMap, endPoint, iterationsCount, retVal);

		if (doIncludeEnds) {
			retVal.push(endPoint);
		} else {
			retVal.shift();
		}

		if (useRealisticPath) {
			retVal = fixRealisticPath(retVal);
		}
		if (useCompressedPath) {
			retVal = shortenPathArray(retVal);
		}


		return retVal;
	}

	/**
	 * Fixes path to more realistic one even if not shortest
	 */
	private function fixRealisticPath(path:Array):Array {
		var newArr:Array = new Array();
		for (var i:Number = 1; i < path.length; i++) {
			newArr.push(path[i - 1]);
			if (path[i].x - path[i - 1].x == 1 && path[i].y - path[i - 1].y == 1 && map[path[i - 1].x][path[i - 1].y + 1] != 1 && map[path[i - 1].x + 1][path[i - 1].y] == 1) {
				newArr.push(new Point(path[i - 1].x, path[i - 1].y + 1));
			} else if (path[i].x - path[i - 1].x == -1 && path[i].y - path[i - 1].y == -1 && map[path[i - 1].x - 1][path[i - 1].y] != 1 && map[path[i - 1].x][path[i - 1].y - 1] == 1) {
				newArr.push(new Point(path[i - 1].x - 1, path[i - 1].y));
			}
		}
		newArr.push(path[path.length - 1]);
		return newArr;
	}

	/**
	 * Optimises Path Arrayt to have less points, and counts only turning points
	 */
	private function shortenPathArray(path:Array):Array {
		var shortPath:Array = new Array();
		var shortIter:int = 0;
		var diffX:Number = 0;
		var diffY:Number = 0;
		for (var i:Number = 0; i < path.length; i++) {
			if (i > 0) {
				if (!(diffX == 0 && diffY == 0) && diffX == path[i].x - path[i - 1].x && diffY == path[i].y - path[i - 1].y) {
					shortIter--;
				}
				diffX = path[i].x - path[i - 1].x;
				diffY = path[i].y - path[i - 1].y;
			}
			shortPath[shortIter] = path[i];
			shortIter++;
		}
		return shortPath;
	}

	/**
	 * Returns Array of Path Points for Given tempMap path lenght array
	 */
	private function getPathArray(tmpMap:Array, pt:Point, iteration:Number, pathArr:Array):Array {
		var tmpPt:Point;
		var i:Number = pt.x;
		var j:Number = pt.y;

		if (iteration == 0) {
			pathArr = pathArr.reverse();
			return pathArr;
		}

		if (i > 0 && tmpMap[i - 1][j] == iteration) {
			tmpPt = new Point(i - 1, j);
			pathArr.push(tmpPt);
			getPathArray(tmpMap, tmpPt, iteration - 1, pathArr);
			return pathArr;
		}
		if (j > 0 && tmpMap[i][j - 1] == iteration) {
			tmpPt = new Point(i, j - 1);
			pathArr.push(tmpPt);
			getPathArray(tmpMap, tmpPt, iteration - 1, pathArr);
			return pathArr;
		}
		if (i < columnCount && tmpMap[i + 1][j] == iteration) {
			tmpPt = new Point(i + 1, j);
			pathArr.push(tmpPt);
			getPathArray(tmpMap, tmpPt, iteration - 1, pathArr);
			return pathArr;
		}
		if (j < rowCount && tmpMap[i][j + 1] == iteration) {
			tmpPt = new Point(i, j + 1);
			pathArr.push(tmpPt);
			getPathArray(tmpMap, tmpPt, iteration - 1, pathArr);
			return pathArr;
		}

		if (canGoDiagonal) {
			if (i > 0 && j > 0 && tmpMap[i - 1][j - 1] == iteration) {
				tmpPt = new Point(i - 1, j - 1);
				pathArr.push(tmpPt);
				getPathArray(tmpMap, tmpPt, iteration - 1, pathArr);
				return pathArr;
			}
			if (i < columnCount && j < rowCount && tmpMap[i + 1][j + 1] == iteration) {
				tmpPt = new Point(i + 1, j + 1);
				pathArr.push(tmpPt);
				getPathArray(tmpMap, tmpPt, iteration - 1, pathArr);
				return pathArr;
			}
			if (i > 0 && j < rowCount && tmpMap[i - 1][j + 1] == iteration) {
				tmpPt = new Point(i - 1, j + 1);
				pathArr.push(tmpPt);
				getPathArray(tmpMap, tmpPt, iteration - 1, pathArr);
				return pathArr;
			}
			if (j > 0 && i < columnCount && tmpMap[i + 1][j - 1] == iteration) {
				tmpPt = new Point(i + 1, j - 1);
				pathArr.push(tmpPt);
				getPathArray(tmpMap, tmpPt, iteration - 1, pathArr);
				return pathArr;
			}
		}

		return new Array();
	}

	/**
	 * Iterates through map to find best rout for current step
	 */
	private function iterate(tmpMap:Array, previousPoints:Array, iteration:Number = 1):Number {
		var newPointArr:Array = new Array();
		for (var key:Number = 0; key < previousPoints.length; key++) {
			var i:Number = previousPoints[key].x;
			var j:Number = previousPoints[key].y;

			// CHeck if route already ended
			if (i > 0 && tmpMap[i - 1][j] == -1)
				return iteration;
			if (j > 0 && tmpMap[i][j - 1] == -1)
				return iteration;
			if (i < columnCount && tmpMap[i + 1][j] == -1)
				return iteration;
			if (j < rowCount && tmpMap[i][j + 1] == -1)
				return iteration;
			if (canGoDiagonal) {
				if (i > 0 && j > 0 && tmpMap[i - 1][j - 1] == -1)
					return iteration;
				if (i < (columnCount - 2) && j < (rowCount - 2) && tmpMap[i + 1][j + 1] == -1)
					return iteration;
				if (i > 0 && j < (rowCount - 2) && tmpMap[i - 1][j + 1] == -1) {
					return iteration;
				}
				if (j > 0 && i < (columnCount - 2) && tmpMap[i + 1][j - 1] == -1)
					return iteration;
			}

			if (i > 0 && tmpMap[i - 1][j] == 0 && map[i - 1][j] != 1) {
				tmpMap[i - 1][j] = iteration + 1;
				newPointArr.push(new Point(i - 1, j));
			}
			if (j > 0 && tmpMap[i][j - 1] == 0 && map[i][j - 1] != 1) {

				tmpMap[i][j - 1] = iteration + 1;
				newPointArr.push(new Point(i, j - 1));
			}
			if (i < (columnCount - 2) && tmpMap[i + 1][j] == 0 && map[i + 1][j] != 1) {
				tmpMap[i + 1][j] = iteration + 1;
				newPointArr.push(new Point(i + 1, j));
			}
			if (j < (rowCount - 2) && tmpMap[i][j + 1] == 0 && map[i][j + 1] != 1) {
				tmpMap[i][j + 1] = iteration + 1;
				newPointArr.push(new Point(i, j + 1));
			}
			if (canGoDiagonal) {
				if (i > 0 && j > 0 && tmpMap[i - 1][j - 1] == 0 && map[i - 1][j - 1] != 1) {
					tmpMap[i - 1][j - 1] = iteration + 1;
					newPointArr.push(new Point(i - 1, j - 1));
				}
				if (i < (columnCount - 2) && j < (rowCount - 2) && tmpMap[i + 1][j + 1] == 0 && map[i + 1][j + 1] != 1) {
					tmpMap[i + 1][j + 1] = iteration + 1;
					newPointArr.push(new Point(i + 1, j + 1));
				}
				if (i > 0 && j < (rowCount - 2) && tmpMap[i - 1][j + 1] == 0 && map[i - 1][j + 1] != 1) {
					tmpMap[i - 1][j + 1] = iteration + 1;
					newPointArr.push(new Point(i - 1, j + 1));
				}
				if (j > 0 && i < (columnCount - 2) && tmpMap[i + 1][j - 1] == 0 && map[i + 1][j - 1] != 1) {
					tmpMap[i + 1][j - 1] = iteration + 1;
					newPointArr.push(new Point(i + 1, j - 1));
				}
			}
		}
		if (iteration > columnCount * rowCount) {
			return iteration;
		}
		iteration = iterate(tmpMap, newPointArr, iteration + 1);
		return iteration;
	}

}

}