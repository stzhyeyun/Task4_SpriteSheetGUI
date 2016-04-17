package
{
	import starling.display.Canvas;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.utils.Align;
	import starling.utils.Color;

	public class TextButton extends Button
	{
		private const _darkSkyBlue:uint = 0x0099cc;
		private const _lightSkyBlue:uint = 0xe6f9ff;
		
		private var _base:Canvas;
		private var _border:Vector.<Canvas>;		
		private var _textField:TextField;
		private var _isIdle:Boolean;
		
		public function TextButton(x:Number, y:Number, width:Number, height:Number,
								   text:String, align:String, border:Boolean)
		{
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
						
			// _base
			_base = new Canvas();
			_base.beginFill();
			_base.drawRectangle(0, 0, width, height);
			_base.endFill();
			_base.touchable = false;
			addChild(_base);
			
			// _border
			if (border)
			{
				_border = new Vector.<Canvas>();
				var thickness:Number = 1;
				
				var top:Canvas = new Canvas();
				top.beginFill(Color.BLACK);
				top.drawRectangle(0, 0, width, thickness);
				top.endFill();
				top.touchable = false;
				_border.push(top);
				
				var bottom:Canvas = new Canvas();
				bottom.beginFill(Color.BLACK);
				bottom.drawRectangle(0, height, width, thickness);
				bottom.endFill();
				bottom.touchable = false;
				_border.push(bottom);
				
				var left:Canvas = new Canvas();
				left.beginFill(Color.BLACK);
				left.drawRectangle(0, 0, thickness, height);
				left.endFill();
				left.touchable = false;
				_border.push(left);
				
				var right:Canvas = new Canvas();
				right.beginFill(Color.BLACK);
				right.drawRectangle(width, 0, thickness, height);
				right.endFill();
				right.touchable = false;
				_border.push(right);	
				
				for (var i:int = 0; i < _border.length; i++)
				{
					addChild(_border[i]);
				}
			}
			
			// _textField
			var format:TextFormat = new TextFormat();
			format.color = Color.BLACK;
			format.bold = true;
			format.font = "Consolas";
			format.horizontalAlign = align;
			format.verticalAlign = Align.CENTER;
						
			_textField = new TextField(width, height, text, format);
			_textField.border = false;
			if (align == Align.CENTER)
			{
				_textField.autoScale = true;	
			}
			else if (align == Align.LEFT)
			{
				_textField.x = 2;
				_textField.width -= 2;
			}
			_textField.addEventListener(TouchEvent.TOUCH, onMouseDown);
			addChild(_textField);		
			
			_isIdle = true;
		}
		
		public override function dispose():void
		{
			if (_base)
			{
				_base.dispose();
			}
			_base = null;
			
			if (_border && _border.length > 0)
			{
				for (var i:int = 0; i < _border.length; i++)
				{
					_border[i].dispose();
					_border[i] = null;
				}
			}
			_border = null;
			
			if (_textField)
			{
				_textField.dispose();
			}
			_textField = null;
			
			super.dispose();
		}
		
		public function get text():String
		{
			return _textField.text;
		}
		
		public function set text(text:String):void
		{
			_textField.text = text;
		}
		
		private function onMouseDown(event:TouchEvent):void
		{			
			var began:Touch = event.getTouch(this, TouchPhase.BEGAN);
			var moved:Touch = event.getTouch(this, TouchPhase.MOVED);
			var ended:Touch = event.getTouch(this, TouchPhase.ENDED);
			var hover:Touch = event.getTouch(this, TouchPhase.HOVER);
			
			if (!began && !moved && !hover || ended)
			{
				if (!_isIdle)
				{
					_base.beginFill(Color.WHITE);
					_base.drawRectangle(0, 0, _base.width, _base.height);
					_base.endFill();
					_isIdle = true;
				}
			}
			else if (began || moved)
			{
				_base.beginFill(_darkSkyBlue);
				_base.drawRectangle(0, 0, _base.width, _base.height);
				_base.endFill();
				_isIdle = false;
			}
			else if (hover)
			{
				_base.beginFill(_lightSkyBlue);
				_base.drawRectangle(0, 0, _base.width, _base.height);
				_base.endFill();
				_isIdle = false;
			}
		}
	}
}