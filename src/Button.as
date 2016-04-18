package
{
	import flash.geom.Point;
	
	import starling.display.Sprite;

	public class Button extends Sprite
	{
		public function Button()
		{
			
		}
		
		/**
		 * 현재 마우스 커서가 버튼 안에 있는지 검사합니다. 
		 * @param mousePos 마우스 커서의 위치입니다.
		 * @return true: 마우스 커서가 버튼 안에 있음 / false: 마우스 커서가 버튼 밖에 있음.
		 * 
		 */
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