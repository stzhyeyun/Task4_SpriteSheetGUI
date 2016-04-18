package
{
	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;

	public class ImageMode extends Mode
	{
		private var _spritesBox:ComboBox;
		private var _prevButton:ImageButton;
		private var _nextButton:ImageButton;
//		private var _quantityField:TextField;
//		private var _nameField:TextField;
		
		private var _showPrevSprite:Function;
		private var _showNextSprite:Function;
		
		public function ImageMode(id:String, showPrevSprite:Function, showNextSprite:Function)
		{
			_id = id;
			_showPrevSprite = showPrevSprite;
			_showNextSprite = showNextSprite;	
		}
		
		public function setUI(
			viewAreaX:Number, viewAreaY:Number, viewAreaWidth:Number, viewAreaHeight:Number,
			UIAssetX:Number, showSprite:Function):Vector.<DisplayObject>
		{
			var objects:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			
			// _spritesBox
			_spritesBox = new ComboBox(
				UIAssetX, viewAreaY + Main.COMBO_BOX_HEIGHT * 3 + Main.UI_ASSET_MARGIN * 2,
				Main.COMBO_BOX_WIDHT, Main.COMBO_BOX_HEIGHT, "Sprite", showSprite);
			_spritesBox.visible = false;
			objects.push(_spritesBox);
			
			var viewAreaRight:Number = viewAreaX + viewAreaWidth;
			var margin:Number = 50;
			var scale:Number = 0.5;
			
			// _prevButton
			var prevBtnTex:Texture = InputManager.getInstance().getTexture("previous");
			if (prevBtnTex)
			{		
				_prevButton = new ImageButton(
					viewAreaX + margin,
					viewAreaY + (viewAreaHeight / 2) - (prevBtnTex.height * scale / 2),
					scale, prevBtnTex);
				_prevButton.visible = false;
				_prevButton.addEventListener(TouchEvent.TOUCH, onPrevButtonClicked);
				objects.push(_prevButton);
			}
			
			// _nextButton
			var nextBtnTex:Texture = InputManager.getInstance().getTexture("next");
			if (nextBtnTex)
			{		
				_nextButton = new ImageButton(
					viewAreaRight - nextBtnTex.width * scale - margin,
					viewAreaY + (viewAreaHeight / 2) - (nextBtnTex.height * scale / 2),
					scale, nextBtnTex);
				_nextButton.visible = false;
				_nextButton.addEventListener(TouchEvent.TOUCH, onNextButtonClicked);
				objects.push(_nextButton);
			}
			
			return objects;
		}
		
		public function activate():void
		{
			if (_spritesBox)
			{
				_spritesBox.visible = true;
				_spritesBox.touchable = true;
			}
			
			if (_prevButton)
			{
				_prevButton.visible = true;
				_prevButton.touchable = true;
			}
			
			if (_nextButton)
			{
				_nextButton.visible = true;
				_nextButton.touchable = true;
			}
			
			if (_quantityField)
			{
				_quantityField.visible = true;
			}
			
			if (_nameField)
			{
				_nameField.visible = true;
			}
		}
		
		public function deactivate():void
		{
			if (_spritesBox)
			{
				_spritesBox.removeAllItems();
				_spritesBox.visible = false;
			}
			
			if (_prevButton)
			{
				_prevButton.visible = false;
			}
			
			if (_nextButton)
			{
				_nextButton.visible = false;
			}
			
			if (_quantityField)
			{
				_quantityField.visible = false;
			}
			
			if (_nameField)
			{
				_nameField.visible = false;
			}
		}
		
		public override function dispose():void
		{
			if (_spritesBox)
			{
				_spritesBox.dispose();
			}
			_spritesBox = null;
			
			super.dispose();
		}
		
		public function get spritesBox():ComboBox
		{
			return _spritesBox;
		}
		
		private function onPrevButtonClicked(event:TouchEvent):void
		{			
			var action:Touch = event.getTouch(_prevButton, TouchPhase.ENDED);
			
			if (action)
			{
				_showPrevSprite();
			}
		}
		
		private function onNextButtonClicked(event:TouchEvent):void
		{			
			var action:Touch = event.getTouch(_nextButton, TouchPhase.ENDED);
			
			if (action)
			{
				_showNextSprite();				
			}
		}
	}
}