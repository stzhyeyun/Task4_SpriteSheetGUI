package
{
	import starling.display.Canvas;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.utils.Align;
	import starling.utils.Color;

	public class RadioButton extends Sprite
	{
		private var _id:int;
		private var _mode:String;
		private var _base:Canvas
		private var _cursor:Canvas;
		private var _textField:TextField;
		private var _changeMode:Function;
		private var _setFocus:Function;
		
		public function RadioButton(
			id:int, x:Number, y:Number, radius:Number, mode:String, changeMode:Function, setFocus:Function)
		{
			_id = id;
			_mode = mode;
			_changeMode = changeMode;
			_setFocus = setFocus;
			
			this.x = x;
			this.y = y;
			
			// _base
			_base = new Canvas();
			_base.beginFill();
			_base.drawCircle(0, 0, radius);
			_base.endFill();
			_base.addEventListener(TouchEvent.TOUCH, onMouseClick);
			addChild(_base);	
			
			// _cursor
			_cursor = new Canvas();
			_cursor.beginFill(0x00cc00); // Light green 
			_cursor.drawCircle(0, 0, radius * 0.6);
			_cursor.endFill();
			_cursor.visible = false;
			addChild(_cursor);	
			
			// _textField
			var format:TextFormat = new TextFormat();
			format.color = Color.BLACK;
			format.bold = true;
			format.font = "Consolas";
			format.horizontalAlign = Align.LEFT;
			format.verticalAlign = Align.TOP;
			
			_textField = new TextField(0, radius * 2 + 5, mode, format);
			_textField.x = radius * 2;
			_textField.y = -radius - 2;
			_textField.autoSize = TextFieldAutoSize.HORIZONTAL;
			_textField.border = false;
			addChild(_textField);	
		}
		
		public function select():void
		{
			_cursor.visible = true;
			
			_changeMode(_mode);
		}
		
		public function deselect():void
		{
			_cursor.visible = false;
		}
		
		public override function dispose():void
		{
			_id = -1;
			_mode = null;
			
			if (_base)
			{
				_base.dispose();
			}
			_base = null;
			
			if (_base)
			{
				_base.dispose();
			}
			_base = null;
			
			if (_cursor)
			{
				_cursor.dispose();
			}
			_cursor = null;
			
			if (_textField)
			{
				_textField.dispose();
			}
			_textField = null;
			
			_changeMode = null;
			_setFocus = null;
			
			super.dispose();
		}
		
		public function get id():int
		{
			return _id;
		}
		
		public function set id(id:int):void
		{
			_id = id;
		}
		
		private function onMouseClick(event:TouchEvent):void
		{			
			var action:Touch = event.getTouch(this, TouchPhase.ENDED);
			
			if (action)
			{
				_setFocus(_id);
			}			
		}
	}
}