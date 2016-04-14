package
{
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;

	public class Button extends Sprite
	{
		private var _image:Image;
		
		public function Button(x:Number, y:Number, width:Number, height:Number, texture:Texture)
		{
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			
			_image = new Image(texture);
			_image.x = x;
			_image.y = y;
			_image.width = width;
			_image.height = height;
			_image.addEventListener(TouchEvent.TOUCH, onMouseDown);
			addChild(_image);
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
				if (action.phase == TouchPhase.BEGAN)
				{
					_image.scale = 0.8;
				}
				else
				{
					if (_image.scale != 1)
					{
						_image.scale = 1;
					}
				}
			}
		}
	}
}