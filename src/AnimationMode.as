package
{
	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;

	public class AnimationMode extends Mode
	{
		private var _playButton:ImageButton;
		private var _stopButton:ImageButton;
		private var _releaseButton:ImageButton;
		
		private var _playSpriteSheet:Function;
		private var _stopAnimation:Function;
		private var _releaseSpriteSheet:Function;
		
		public function AnimationMode(
			id:String, playSpriteSheet:Function, stopAnimation:Function, releaseSpriteSheet:Function)
		{
			_id = id;
			
			_playSpriteSheet = playSpriteSheet;
			_stopAnimation = stopAnimation;
			_releaseSpriteSheet = releaseSpriteSheet;
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
				_playButton.addEventListener(TouchEvent.TOUCH, onPlayButtonClicked);
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
				_stopButton.addEventListener(TouchEvent.TOUCH, onStopButtonClicked);
				objects.push(_stopButton);
			}
			
			// _releaseButton
			var releaseBtnTex:Texture = InputManager.getInstance().getTexture("release");
			if (releaseBtnTex)
			{		
				_releaseButton = new ImageButton(
					viewAreaRight - releaseBtnTex.width * scale - margin,
					_stopButton.y + releaseBtnTex.height * scale + margin,
					scale, releaseBtnTex);
				_releaseButton.visible = false;
				_releaseButton.addEventListener(TouchEvent.TOUCH, onReleaseButtonClicked);
				objects.push(_releaseButton);
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
			
			if (_releaseButton)
			{
				_releaseButton.visible = true;
				_releaseButton.touchable = true;
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
			
			if (_releaseButton)
			{
				_releaseButton.visible = false;
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
		
		private function onPlayButtonClicked(event:TouchEvent):void
		{			
			var action:Touch = event.getTouch(_playButton, TouchPhase.ENDED);
			
			if (action)
			{
				if (_playSpriteSheet)
				{
					_playSpriteSheet();
				}
			}
		}
		
		private function onStopButtonClicked(event:TouchEvent):void
		{			
			var action:Touch = event.getTouch(_stopButton, TouchPhase.ENDED);
			
			if (action)
			{
				if (_stopAnimation)
				{
					_stopAnimation();
				}
			}
		}
		
		private function onReleaseButtonClicked(event:TouchEvent):void
		{			
			var action:Touch = event.getTouch(_releaseButton, TouchPhase.ENDED);
			
			if (action)
			{
				if (_releaseSpriteSheet)
				{
					_releaseSpriteSheet();
				}
			}
		}
	}
}