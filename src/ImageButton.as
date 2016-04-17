package
{
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;

	public class ImageButton extends Button
	{
		private var _image:Image;
		private var _defaultX:Number;
		private var _defaultY:Number;
		private var _defaultScale:Number;
		private var _downX:Number;
		private var _downY:Number;
		private var _downScale:Number;
		
		public function ImageButton(x:Number, y:Number, scale:Number, texture:Texture)
		{
			if (!texture)
			{
				return;	
			}
			
			var downRate:Number = 0.95;
			
			_defaultScale = scale;
			_downScale = _defaultScale * downRate;
			
			_image = new Image(texture);
			_image.scale = _defaultScale;
			_image.addEventListener(TouchEvent.TOUCH, onMouseDown);
			addChild(_image);
			
			this.x = x;
			this.y = y;
			this.width = _image.width;
			this.height = _image.height;
			
			_defaultX = x;
			_defaultY = y;
			_downX = _defaultX + (width - width * downRate) / 2;
			_downY = _defaultY + (height - height * downRate) / 2;
		}
		
		public override function dispose():void
		{
			if (_image)
			{
				_image.dispose();
			}
			_image = null;
			
			super.dispose();
		}
		
		private function onMouseDown(event:TouchEvent):void
		{			
			var action:Touch = event.getTouch(this);
			
			if (action)
			{
				if (action.phase == TouchPhase.BEGAN || action.phase == TouchPhase.MOVED)
				{
					this.x = _downX;
					this.y = _downY;
					_image.scale = _downScale;
				}
				else
				{
					if (_image.scale != _defaultScale)
					{
						this.x = _defaultX;
						this.y = _defaultY;
						_image.scale = _defaultScale;
					}
				}
			}
		}
	}
}