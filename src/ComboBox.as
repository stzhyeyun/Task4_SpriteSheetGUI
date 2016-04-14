package
{
	import flash.display.Shape;
	import starling.display.Sprite;

	public class ComboBox extends Sprite
	{
		private var _dropdownButton:Button;
		private var _selectedBox:Shape;
		private var _dropdownBox:Shape;
		private var _dropdown:Vector.<TextButton>;
		
		//private var _scrollUpButton:Button;
		//private var _scrollDownButton:Button;
		//private var _scrollBar:Button;
		
		public function ComboBox()
		{
		}
		
		public override function dispose():void
		{
			// to do
			
			
			super.dispose();
		}
	}
}