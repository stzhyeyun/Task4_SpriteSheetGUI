package
{
	import starling.display.DisplayObject;

	public class ImageMode extends Mode
	{
		private var _spritesBox:ComboBox;
		
		public function ImageMode(id:String)
		{
			_id = id;
		}
		
		public function setUI(
			UIAssetX:Number, viewAreaY:Number, viewAreaBottom:Number):Vector.<DisplayObject>
		{
			// to do
			// invisible
			
			return null;
		}
		
		public function activate():void
		{
			if (_spritesBox)
			{
				_spritesBox.visible = true;
				_spritesBox.touchable = true;
			}
		}
		
		public function deactivate():void
		{
			if (_spritesBox)
			{
				_spritesBox.visible = false;
			}
		}
		
		public override function dispose():void
		{
			if (_spritesBox)
			{
				_spritesBox.dispose();
			}
			_spritesBox = null;
			
			super.dispose();
		}
	}
}