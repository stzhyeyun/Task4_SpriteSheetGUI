package
{
	import starling.display.DisplayObject;

	public class AnimationMode extends Mode
	{
		private var _playButton:ImageButton;
		private var _stopButton:ImageButton;
		private var _removeButton:ImageButton;
		
		public function AnimationMode(id:String)
		{
			_id = id;
		}
		
		public function setUI(
			viewAreaX:Number, viewAreaY:Number, viewAreaWidth:Number, viewAreaHeight:Number,
			UIAssetX:Number):Vector.<DisplayObject>
		{
			// to do
			// invisible
			
			return null;
		}
		
		public function activate():void
		{
			if (_playButton)
			{
				_playButton.visible = true;
				_playButton.touchable = true;
			}
			
			if (_stopButton)
			{
				_stopButton.visible = true;
				_stopButton.touchable = true;
			}
			
			if (_removeButton)
			{
				_removeButton.visible = true;
				_removeButton.touchable = true;
			}
		}
		
		public function deactivate():void
		{
			if (_playButton)
			{
				_playButton.visible = false;
			}
			
			if (_stopButton)
			{
				_stopButton.visible = false;
			}
			
			if (_removeButton)
			{
				_removeButton.visible = false;
			}
		}
		
		public override function dispose():void
		{
			if (_playButton)
			{
				_playButton.dispose();
			}
			_playButton = null;

			if (_stopButton)
			{
				_stopButton.dispose();
			}
			_stopButton = null;
			
			if (_removeButton)
			{
				_removeButton.dispose();
			}
			_removeButton = null;
			
			super.dispose();
		}
	}
}