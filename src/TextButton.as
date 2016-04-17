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
		private var _idle:Canvas;
		private var _down:Canvas;
		private var _lines:Vector.<Canvas>;		
		private var _textField:TextField;
		
		public function TextButton(x:Number, y:Number, width:Number, height:Number, text:String)
		{
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
						
			// _idle
			_idle = new Canvas();
			_idle.beginFill();
			_idle.drawRectangle(0, 0, width, height);
			_idle.endFill();
			_idle.touchable = false;
			addChild(_idle);
			
			// _down
			_down = new Canvas();
			_down.beginFill(0xe6f9ff); // Light sky blue
			_down.drawRectangle(0, 0, width, height);
			_down.endFill();
			_down.touchable = false;
			_down.visible = false;
			addChild(_down);
			
			// _lines
			_lines = new Vector.<Canvas>();
			var thickness:Number = 1;
			
			var top:Canvas = new Canvas();
			top.beginFill(Color.BLACK);
			top.drawRectangle(0, 0, width, thickness);
			top.endFill();
			top.touchable = false;
			_lines.push(top);
			
			var bottom:Canvas = new Canvas();
			bottom.beginFill(Color.BLACK);
			bottom.drawRectangle(0, height, width, thickness);
			bottom.endFill();
			bottom.touchable = false;
			_lines.push(bottom);
			
			var left:Canvas = new Canvas();
			left.beginFill(Color.BLACK);
			left.drawRectangle(0, 0, thickness, height);
			left.endFill();
			left.touchable = false;
			_lines.push(left);
			
			var right:Canvas = new Canvas();
			right.beginFill(Color.BLACK);
			right.drawRectangle(width, 0, thickness, height);
			right.endFill();
			right.touchable = false;
			_lines.push(right);			
			
			for (var i:int = 0; i < _lines.length; i++)
			{
				addChild(_lines[i]);
			}
			
			// _textField
			var format:TextFormat = new TextFormat();
			format.color = Color.BLACK;
			format.bold = true;
			format.font = "Consolas";
			format.horizontalAlign = Align.CENTER;
			format.verticalAlign = Align.CENTER;
						
			_textField = new TextField(width, height, text, format);
			_textField.border = false;
			_textField.autoScale = true;
			_textField.addEventListener(TouchEvent.TOUCH, onMouseDown);
			addChild(_textField);			
		}
		
		public override function dispose():void
		{
			if (_idle)
			{
				_idle.dispose();
			}
			_idle = null;
			
			if (_down)
			{
				_down.dispose();
			}
			_down = null;
			
			if (_lines && _lines.length > 0)
			{
				for (var i:int = 0; i < _lines.length; i++)
				{
					_lines[i].dispose();
					_lines[i] = null;
				}
			}
			_lines = null;
			
			if (_textField)
			{
				_textField.dispose();
			}
			_textField = null;
			
			super.dispose();
		}
		
		private function onMouseDown(event:TouchEvent):void
		{			
			var action:Touch = event.getTouch(this);
			
			if (action)
			{
				if (action.phase == TouchPhase.BEGAN || action.phase == TouchPhase.MOVED)
				{
					_down.visible = true;
				}
				else
				{
					if (_down.visible)
					{
						_down.visible = false;
					}
				}
			}
		}
	}
}