package
{
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.textures.Texture;
	import starling.utils.Align;
	import starling.utils.Color;

	public class ComboBox extends Sprite
	{
		private var _titleField:TextField;
		private var _selectedBox:TextButton;
		private var _dropdownButton:ImageButton;
		private var _items:Vector.<TextButton>;
		private var _isSelected:Boolean;
		private var _isDown:Boolean;
		private var _callback:Function;
		
		//private var _scrollUpButton:Button;
		//private var _scrollDownButton:Button;
		//private var _scrollBar:Button;
		
		public function ComboBox(x:Number, y:Number, width:Number, height:Number, title:String, callback:Function)
		{
			this.x = x;
			this.y = y;
			
			// _titleField
			var format:TextFormat = new TextFormat();
			format.color = Color.BLACK;
			format.bold = true;
			format.font = "Consolas";
			format.horizontalAlign = Align.LEFT;
			format.verticalAlign = Align.CENTER;
			
			_titleField = new TextField(width, height, title, format);
			_titleField.border = false;
			addChild(_titleField);
			
			// _selectedBox
			_selectedBox =new TextButton(
				0, _titleField.height, width, height, "", Align.LEFT, false);
			_selectedBox.touchable = false;
			addChild(_selectedBox);
			
			//_dropdownButton
			var downBtnTex:Texture = InputManager.getInstance().getTexture("dropdown");
			var scale:Number = 0.15;
			if (downBtnTex)
			{		
				_dropdownButton = new ImageButton(
					_selectedBox.width - downBtnTex.width * scale, _titleField.height, scale, downBtnTex);
				_dropdownButton.addEventListener(TouchEvent.TOUCH, onDropdownButtonClicked);
				addChild(_dropdownButton);
			}
			
			_isSelected = false;
			_isDown = false;
			_callback = callback;
		}
		
		public override function dispose():void
		{
			if (_selectedBox)
			{
				_selectedBox.dispose();
			}
			_selectedBox = null;
			
			if (_dropdownButton)
			{
				_dropdownButton.dispose();
			}
			_dropdownButton = null;

			if (_items && _items.length > 0)
			{
				for (var i:int = 0; i < _items.length; i++)
				{
					_items[i].dispose();
					_items[i] = null;
				}				
			}
			_items = null;
			
			_callback = null;
			
			super.dispose();
		}
		
		public function addItem(name:String):void
		{
			if (!_items)
			{
				_items = new Vector.<TextButton>();
			}
			
			var item:TextButton =new TextButton(
				_titleField.x, _items.length * _titleField.height + _titleField.height * 2,
				_selectedBox.width, _selectedBox.height,
				name, Align.LEFT, false);
			item.name = name;
			item.visible = false;
			item.addEventListener(TouchEvent.TOUCH, onItemClicked);
			addChild(item);

			_items.push(item);
		}
		
		public function removeItem(name:String):void
		{
			if (_items && _items.length > 0)
			{
				var removedIndex:int;
				for (var i:int = 0; i < _items.length; i++)
				{
					if (_items[i].name == name)
					{
						_items[i].dispose();
						_items[i] = null;
						_items.removeAt(i);
						removedIndex = i;
					}
				}
				
				if (_items.length > 0)
				{
					for (var i:int = removedIndex; i < _items.length; i++)
					{
						_items[i].y -= _selectedBox.height;
					}
				}
			}
		}
		
		public function removeAllItems():void
		{
			if (_items && _items.length > 0)
			{
				for (var i:int = 0; i < _items.length; i++)
				{
					_items[i].dispose();
					_items[i] = null;
				}
				_items = null;
				
				_selectedBox.text = "";
			}
		}

		public function showMessage(message:String):void
		{
			_selectedBox.text = message;
		}

		private function open():void
		{
			if (_items && _items.length > 0)
			{
				for (var i:int = 0; i < _items.length; i++)
				{
					_items[i].visible = true;
					_items[i].touchable = true;
				}
			}
			
			_isDown = true;
		}
		
		private function close():void
		{
			if (_items && _items.length > 0)
			{
				for (var i:int = 0; i < _items.length; i++)
				{
					_items[i].visible = false;
				}
			}
			
			_isDown = false;
		}
		
		private function onDropdownButtonClicked(event:TouchEvent):void
		{			
			var action:Touch = event.getTouch(this, TouchPhase.ENDED);
			
			if (action)
			{
				if (_dropdownButton.isIn(action.getLocation(this)))
				{
					if (_isDown)
					{
						close();
					}
					else
					{
						open();
					}
				}
			}
		}
		
		private function onItemClicked(event:TouchEvent):void
		{			
			var action:Touch = event.getTouch(this, TouchPhase.ENDED);
			
			if (action)
			{
				var item:TextButton = event.currentTarget as TextButton;
				if (item)
				{
					if (item.isIn(action.getLocation(this)))
					{
						_callback(item.text, _selectedBox.text);
						_selectedBox.text = item.text;
						
						close();
					}
				}
			}
		}
	}
}