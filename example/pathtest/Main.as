package pathtest {
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;

import utils.pathfind.AStarPathfinder;

/**
 * ...
 * @author
 */
public class Main extends Sprite {

	private static const CELL_SIZE:int = 20;
	private static const CELL_SIZE_HALF:int = CELL_SIZE / 2;
	private static const CELL_SIZE_QUATER:int = CELL_SIZE / 4;
	private static const CELL_SIZE_EIGHT:int = CELL_SIZE / 8;

	private var debugLayer:Shape = new Shape();

	public function Main() {
		if (stage) init();
		else addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(e:Event = null):void {
		removeEventListener(Event.ADDED_TO_STAGE, init);
		// entry point

		trace("hi..");

		var startPoint:Point = new Point(1, 1);
		var endPoint:Point = new Point(8, 8);

		addChild(debugLayer);

		var map:Array = [ //
			[0, 0, 1, 1, 0, 0, 0, 0, 0, 0], //
			[0, 0, 1, 1, 0, 0, 0, 0, 0, 0], //
			[0, 0, 1, 1, 0, 0, 0, 0, 0, 0], //
			[0, 0, 1, 1, 0, 0, 0, 0, 0, 0], //
			[0, 0, 0, 0, 0, 0, 0, 0, 0, 0], //
			[0, 0, 1, 1, 0, 0, 0, 0, 0, 0], //
			[0, 0, 1, 1, 0, 0, 0, 0, 0, 0], //
			[0, 0, 1, 1, 0, 0, 0, 0, 0, 0], //
			[0, 0, 1, 1, 0, 0, 0, 0, 0, 0], //
			[0, 0, 1, 1, 0, 0, 0, 0, 0, 0] //
		];

		var pathFinder:AStarPathfinder = new AStarPathfinder(false, false, false);
		pathFinder.loadMap(map, 10, 10, "");
		var path:Array = pathFinder.getPath(startPoint, endPoint, false);

		trace(path);
		// draw grid.
		debugLayer.graphics.lineStyle(1, 0x0);
		for (var x:int = 0; x < map.length; x++) {
			var row:Array = map[x];
			for (var y:int = 0; y < row.length; y++) {

				if (row[y] == 0) {
					debugLayer.graphics.beginFill(0xFFFFFF);
				} else {
					debugLayer.graphics.beginFill(0x0);
				}

				debugLayer.graphics.drawRect(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE);

				debugLayer.graphics.endFill();
			}
		}

		// draw points
		debugLayer.graphics.lineStyle(0, 0, 0);

		debugLayer.graphics.beginFill(0xFFFF00);
		debugLayer.graphics.drawCircle(startPoint.x * CELL_SIZE + CELL_SIZE_HALF, startPoint.y * CELL_SIZE + CELL_SIZE_HALF, CELL_SIZE_QUATER);
		debugLayer.graphics.endFill();

		debugLayer.graphics.beginFill(0x00FF00);
		debugLayer.graphics.drawCircle(endPoint.x * CELL_SIZE + CELL_SIZE_HALF, endPoint.y * CELL_SIZE + CELL_SIZE_HALF, CELL_SIZE_QUATER);
		debugLayer.graphics.endFill();

		debugLayer.graphics.lineStyle(3, 0xFF00FF, 0.5);
		debugLayer.graphics.moveTo(path[0].x * CELL_SIZE + CELL_SIZE_HALF, path[0].y * CELL_SIZE + CELL_SIZE_HALF);
		debugLayer.graphics.drawCircle(path[0].x * CELL_SIZE + CELL_SIZE_HALF, path[0].y * CELL_SIZE + CELL_SIZE_HALF, CELL_SIZE_EIGHT);
		for (var i:int = 1; i < path.length; i++) {
			debugLayer.graphics.moveTo(path[i-1].x * CELL_SIZE + CELL_SIZE_HALF, path[i-1].y * CELL_SIZE + CELL_SIZE_HALF);
			debugLayer.graphics.lineTo(path[i].x * CELL_SIZE + CELL_SIZE_HALF, path[i].y * CELL_SIZE + CELL_SIZE_HALF);
			debugLayer.graphics.drawCircle(path[i].x * CELL_SIZE + CELL_SIZE_HALF, path[i].y * CELL_SIZE + CELL_SIZE_HALF, CELL_SIZE_EIGHT);
		}

	}

}

}