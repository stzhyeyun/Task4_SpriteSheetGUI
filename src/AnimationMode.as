package
{
	import starling.display.DisplayObject;

	public class AnimationMode extends Mode
	{
		private var _playButton:Button;
		private var _stopButton:Button;
		private var _releaseButton:Button;
		
		public function AnimationMode(id:String)
		{
			_id = id;
		}
		
		public override function setUI():Vector.<DisplayObject>
		{
			// to do
			// invisible
			
			return null;
		}
		
		public override function activate():void
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
			
			if (_releaseButton)
			{
				_releaseButton.visible = true;
				_releaseButton.touchable = true;
			}
		}
		
		public override function deactivate():void
		{
			if (_playButton)
			{
				_playButton.visible = false;
				_playButton.touchable = false;
			}
			
			if (_stopButton)
			{
				_stopButton.visible = false;
				_stopButton.touchable = false;
			}
			
			if (_releaseButton)
			{
				_releaseButton.visible = false;
				_releaseButton.touchable = false;
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
			
			if (_releaseButton)
			{
				_releaseButton.dispose();
			}
			_releaseButton = null;
			
			super.dispose();
		}
	}
}