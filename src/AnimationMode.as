package
{
	import starling.display.DisplayObject;
	import starling.textures.Texture;

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
			var objects:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			
			var viewAreaRight:Number = viewAreaX + viewAreaWidth;
			var margin:Number = 10;
			var scale:Number = 0.3;
			
			// _playButton
			var playBtnTex:Texture = InputManager.getInstance().getTexture("play");
			if (playBtnTex)
			{		
				_playButton = new ImageButton(
					viewAreaRight - playBtnTex.width * scale - margin, viewAreaY + margin,
					scale, playBtnTex);
				_playButton.visible = false;
				objects.push(_playButton);
			}
			
			// _stopButton
			var stopBtnTex:Texture = InputManager.getInstance().getTexture("stop");
			if (stopBtnTex)
			{	
				_stopButton = new ImageButton(
					viewAreaRight - stopBtnTex.width * scale - margin,
					_playButton.y + stopBtnTex.height * scale + margin,
					scale, stopBtnTex);
				_stopButton.visible = false;
				objects.push(_stopButton);
			}
			
			// _removeButton
			var removeBtnTex:Texture = InputManager.getInstance().getTexture("remove");
			if (removeBtnTex)
			{		
				_removeButton = new ImageButton(
					viewAreaRight - removeBtnTex.width * scale - margin,
					_stopButton.y + removeBtnTex.height * scale + margin,
					scale, removeBtnTex);
				_removeButton.visible = false;
				objects.push(_removeButton);
			}
			
			return objects;
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