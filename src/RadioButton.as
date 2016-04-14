package
{
	import flash.display.Shape;
	
	import starling.display.Sprite;

	public class RadioButton extends Sprite
	{
		private var _cursor:Shape;
		private var _setFocus:Function;
		
		public function RadioButton(setFocus:Function)
		{
			_setFocus = setFocus;
			
			// graphics -> circle
		}
		
		public override function dispose():void
		{
			// to do
			
			
			super.dispose();
		}
	}
}