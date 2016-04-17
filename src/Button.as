package
{
	import flash.geom.Point;
	
	import starling.display.Sprite;

	public class Button extends Sprite
	{
		public function Button()
		{
			
		}
		
		public function isIn(mousePos:Point):Boolean
		{
			var result:Boolean = false;
			
			if (mousePos.x >= this.x && mousePos.x <= this.x + this.width
				&& mousePos.y >= this.y  && mousePos.y <= this.y + this.height)
			{
				result = true;
			}
			
			return result;
		}
	}
}