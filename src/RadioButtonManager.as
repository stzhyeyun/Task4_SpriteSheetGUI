package
{
	public class RadioButtonManager
	{
		private var _buttons:Vector.<RadioButton>;
		private var _selectedButtonId:int;
		
		/**
		 * 복수의 라디오 버튼에게 유니크한 커서를 운용하기 위하여 매니저를 통해 관리합니다. 
		 * 
		 */
		public function RadioButtonManager()
		{
		}
		
		public function addButton(x:Number, y:Number, radius:Number, mode:String, changeMode:Function):RadioButton
		{
			if (!_buttons)
			{
				_buttons = new Vector.<RadioButton>();
			}
			var button:RadioButton = new RadioButton(_buttons.length, x, y, radius, mode, changeMode, setFocus);
			_buttons.push(button);
			
			if (_buttons.length == 1)
			{
				setFocus(0);
			}
			
			return button;
		}
		
		public function removeButton(removeButtonId:int):void
		{
			// 버튼 삭제
			if (_buttons && removeButtonId >= 0 && removeButtonId < _buttons.length)
			{
				_buttons[removeButtonId].dispose();
				_buttons[removeButtonId] = null;
				_buttons.removeAt(removeButtonId);
			}
			
			// 잔여 버튼 ID 및 SelectedButton 재설정
			if (_buttons && _buttons.length > 0)
			{
				for (var i:int = 0; i < _buttons.length; i++)
				{
					_buttons[i].id = i;
				}
				setFocus(0);
			}
			else
			{
				_buttons = null;
				_selectedButtonId = -1;
			}
		}
		
		/**
		 * 커서를 이동합니다. 
		 * @param selectedButtonId 커서를 이동할 버튼의 ID입니다.
		 * 
		 */
		public function setFocus(selectedButtonId:int):void
		{
			if (_buttons && selectedButtonId >= 0 && selectedButtonId < _buttons.length)
			{
				_buttons[_selectedButtonId].deselect();
				
				_selectedButtonId = selectedButtonId;
				
				_buttons[_selectedButtonId].select();
			}
		}
		
		public function dispose():void
		{
			if (_buttons)
			{
				for (var i:int = 0; i < _buttons.length; i++)
				{
					_buttons[i].dispose();
					_buttons[i] = null;
				}
			}
			_buttons = null;
			
			_selectedButtonId = -1;
		}
	}
}