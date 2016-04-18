package
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import starling.core.Starling;
	import starling.display.Canvas;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.utils.Align;
	
	public class Main extends Sprite
	{
		public static const UI_ASSET_MARGIN:Number = 20;
		public static const COMBO_BOX_WIDHT:Number = 200;
		public static const COMBO_BOX_HEIGHT:Number = 20;

		private const _RADIO_BTN_RADIUS:Number = 6;
		
		private const _SPRITE_SHEET_BOX_MSG:String = "Select Sprite Sheet";
		private const _DELAY:Number = 1500;
		
		private var _actualViewAreaWidth:Number;
		private var _actualViewAreaHeight:Number;
		
		// UI
		private var _viewArea:Canvas;
		private var _browserButton:TextButton;
		private var _spriteSheetBox:ComboBox;
		private var _radioButtonManager:RadioButtonManager;
		private var _modes:Dictionary; // Mode
		private var _currMode:String;
		
		// Animation -> 별도 클래스로 구성?
		private var _timer:Timer;
		private var _resourceFolder:File;
		private var _selectedSpriteSheet:SpriteSheet;
		private var _numSprite:int;
		private var _currSpriteIndex:int = -1;
		private var _isPlaying:Boolean = false;
		
		public function Main()
		{
			InputManager.getInstance().loadRequest(
				ResourceType.UI_ASSET,
				File.applicationDirectory.resolvePath("Resources"), "icons",
				setUI, true);
						
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExit);
		}
		
		private function setUI():void
		{
			// _viewArea
			_viewArea = new Canvas();
			_viewArea.beginFill();
			_viewArea.drawRectangle(
				0, 0,
				Starling.current.stage.stageWidth * 0.7, Starling.current.stage.stageHeight * 0.7);
			_viewArea.endFill();
			_viewArea.x = Starling.current.stage.stageWidth * 0.05;
			_viewArea.y = (Starling.current.stage.stageHeight / 2) - (_viewArea.height / 2);
			addChild(_viewArea);
			
			var viewAreaMargin:Number = 150;
			_actualViewAreaWidth = _viewArea.width - viewAreaMargin;
			_actualViewAreaHeight = _viewArea.height - viewAreaMargin;
			
			var UIAssetX:Number = _viewArea.x + _viewArea.width + UI_ASSET_MARGIN;
			
			// _browserButton
			_browserButton = new TextButton(UIAssetX, _viewArea.y, COMBO_BOX_WIDHT, 30,
				"Select Resource Folder", Align.CENTER, true);
			_browserButton.addEventListener(TouchEvent.TOUCH, onBrowserButtonClicked);
			addChild(_browserButton);
			
			// _spriteSheetBox
			_spriteSheetBox = new ComboBox(
				UIAssetX, _viewArea.y + _browserButton.height + UI_ASSET_MARGIN,
				COMBO_BOX_WIDHT, COMBO_BOX_HEIGHT, "Sprite Sheet", loadSpriteSheet);
			addChild(_spriteSheetBox);
			
			// _radioButtonManager
			var viewAreaBottom:Number = _viewArea.y + _viewArea.height;
			
			_radioButtonManager = new RadioButtonManager();
			addChild(_radioButtonManager.addButton(
				UIAssetX, viewAreaBottom - _RADIO_BTN_RADIUS * 6, _RADIO_BTN_RADIUS, Mode.ANIMATION_MODE, changeMode));
			addChild(_radioButtonManager.addButton(
				UIAssetX, viewAreaBottom - _RADIO_BTN_RADIUS * 2, _RADIO_BTN_RADIUS, Mode.IMAGE_MODE, changeMode));
			
			// Mode
			setMode(_viewArea.x, _viewArea.y, _viewArea.width, _viewArea.height, UIAssetX);			
		}
		
		private function setMode(
			viewAreaX:Number, viewAreaY:Number, viewAreaWidth:Number, viewAreaHeight:Number, UIAssetX:Number):void
		{
			_modes = new Dictionary();
			
			// Image Mode
			_modes[Mode.IMAGE_MODE] = new ImageMode(Mode.IMAGE_MODE, showPrevSprite, showNextSprite);
			var imgModeUI:Vector.<DisplayObject> =
				_modes[Mode.IMAGE_MODE].setUI(viewAreaX, viewAreaY, viewAreaWidth, viewAreaHeight, UIAssetX, showSprite);
			
			if (imgModeUI)
			{
				for (var i:int = 0; i < imgModeUI.length; i++)
				{
					addChild(imgModeUI[i]);
				}
			}
			
			// Animation Mode
			_modes[Mode.ANIMATION_MODE] = new AnimationMode(
				Mode.ANIMATION_MODE, playSpriteSheet, stopAnimation, releaseSpriteSheet);
			var animModeUI:Vector.<DisplayObject> =
				_modes[Mode.ANIMATION_MODE].setUI(viewAreaX, viewAreaY, viewAreaWidth, viewAreaHeight, UIAssetX);
			
			if (animModeUI)
			{
				for (var i:int = 0; i < animModeUI.length; i++)
				{
					addChild(animModeUI[i]);
				}
			}
			
			changeMode(Mode.ANIMATION_MODE);
		}
		
		private function changeMode(mode:String):void
		{
			if (_modes && _modes[Mode.ANIMATION_MODE] && _modes[Mode.IMAGE_MODE])
			{
				if (mode == Mode.ANIMATION_MODE)
				{
					_modes[Mode.IMAGE_MODE].deactivate();
					_modes[Mode.ANIMATION_MODE].activate();
					
					if (_selectedSpriteSheet)
					{
						var object:DisplayObject;	
						if (_currSpriteIndex >= 0 && _currSpriteIndex < _numSprite)
						{
							object = _viewArea.getChildByName(_selectedSpriteSheet.sprites[_currSpriteIndex].name);
							
							if (object)
							{
								object.visible = false;
							}
						}
					}
					
					_currMode = mode;
				}
				else if (mode == Mode.IMAGE_MODE)
				{
					_modes[Mode.ANIMATION_MODE].deactivate();
					_modes[Mode.IMAGE_MODE].activate();
					addChild(_spriteSheetBox);
					
					if (_selectedSpriteSheet)
					{
						resetAnimator();
						
						_spriteSheetBox.showMessage(_SPRITE_SHEET_BOX_MSG);
					}
					
					_currMode = mode;
				}
			}
		}
		
		private function loadSpriteSheet(currItemName:String, prevItemName:String):void
		{
			resetAnimator();
			
			InputManager.getInstance().loadRequest(
				ResourceType.SPRITE_SHEET, _resourceFolder, currItemName,
				showSpriteSheet, true);
		}
		
		private function showSpriteSheet(contents:SpriteSheet):void
		{
			if (contents)
			{
				_selectedSpriteSheet = contents;
				_numSprite = _selectedSpriteSheet.sprites.length;

				_viewArea.addChild(adjustViewingItem(_selectedSpriteSheet.spriteSheet));
				_viewArea.getChildByName(_selectedSpriteSheet.spriteSheet.name).visible = true;
				
				if (_currMode == Mode.IMAGE_MODE)
				{
					for (var i:int = 0; i < _selectedSpriteSheet.sprites.length; i++)
					{
						ImageMode(_modes[Mode.IMAGE_MODE]).spritesBox.
							addItem(_selectedSpriteSheet.sprites[i].name);
						
						ImageMode(_modes[Mode.IMAGE_MODE]).spritesBox.
							showMessage("Select Sprite");
					}
				}
			}
		}
		
		private function showSprite(currItemName:String, prevItemName:String):void
		{
			_viewArea.getChildByName(_selectedSpriteSheet.spriteSheet.name).visible = false;
			
			if (prevItemName)
			{
				var object:DisplayObject = _viewArea.getChildByName(prevItemName);
				
				if (object)
				{
					object.visible = false;
				}
			}
			
			_viewArea.addChild(adjustViewingItem(_selectedSpriteSheet.find(currItemName)));
			_viewArea.getChildByName(currItemName).visible = true;
			
			_currSpriteIndex = _selectedSpriteSheet.getIndex(currItemName);
		}
		
		private function playSpriteSheet():void
		{
			if (!_selectedSpriteSheet)
			{
				return;
			}
				
			if (!_timer)
			{
				_timer = new Timer(_DELAY);
				_timer.addEventListener(TimerEvent.TIMER, onTick);
			}
			_timer.start();
			_isPlaying = true;
			
			_viewArea.getChildByName(_selectedSpriteSheet.spriteSheet.name).visible = false;
		}
		
		private function stopAnimation():void
		{
			if (_isPlaying)
			{
				resetAnimator();
				_viewArea.getChildByName(_selectedSpriteSheet.spriteSheet.name).visible = true;
			}
		}
		
		private function releaseSpriteSheet():void
		{
			if (!_selectedSpriteSheet)
			{
				return;
			}
			
			var name:String = _selectedSpriteSheet.spriteSheet.name;
			
			// @this
			cleanAnimator();
			
			// @_spriteSheetBox
			_spriteSheetBox.removeItem(name);
			
			// @InputManager
			InputManager.getInstance().releaseRequest(name);
		}
		
		private function showPrevSprite():void
		{
			if (!_selectedSpriteSheet)
			{
				return;
			}
			
			_viewArea.getChildByName(_selectedSpriteSheet.spriteSheet.name).visible = false;
			
			var prevIndex:int = _currSpriteIndex;
			_currSpriteIndex--;
			
			if (_currSpriteIndex < 0)
			{
				_currSpriteIndex = _numSprite - 1;
			}
			
			if (prevIndex >= 0)
			{
				_viewArea.getChildByName(_selectedSpriteSheet.sprites[prevIndex].name).visible = false;
			}
			
			_viewArea.addChild(adjustViewingItem(_selectedSpriteSheet.sprites[_currSpriteIndex]));
			_viewArea.getChildByName(_selectedSpriteSheet.sprites[_currSpriteIndex].name).visible = true;
		}
		
		private function showNextSprite():void
		{
			if (!_selectedSpriteSheet)
			{
				return;
			}
			
			_viewArea.getChildByName(_selectedSpriteSheet.spriteSheet.name).visible = false;
			
			var prevIndex:int = _currSpriteIndex;
			_currSpriteIndex++;
			
			if (_currSpriteIndex > _numSprite - 1)
			{
				_currSpriteIndex = 0;
			}
			
			if (prevIndex >= 0)
			{
				_viewArea.getChildByName(_selectedSpriteSheet.sprites[prevIndex].name).visible = false;
			}
			
			_viewArea.addChild(adjustViewingItem(_selectedSpriteSheet.sprites[_currSpriteIndex]));
			_viewArea.getChildByName(_selectedSpriteSheet.sprites[_currSpriteIndex].name).visible = true;
		}
		
		private function adjustViewingItem(item:DisplayObject):DisplayObject
		{
			var scale:Number = item.scale;
			
			if (item.width > _actualViewAreaWidth)
			{
				scale = scale * _actualViewAreaWidth / item.width; 
			}
			
			if (item.height > _actualViewAreaHeight)
			{
				scale = scale * _actualViewAreaHeight / item.height;
			}
			
			item.scale = scale;
			item.x = (_viewArea.width / 2) - (item.width / 2);
			item.y = (_viewArea.height / 2) - (item.height / 2);
			
			return item;
		}
		
		private function resetAnimator():void
		{
			if (!_selectedSpriteSheet)
			{
				return;
			}
			
			if (_timer)
			{
				_timer.stop();
				_timer.reset();
			}
			
			_viewArea.getChildByName(_selectedSpriteSheet.spriteSheet.name).visible = false;
			
			for (var i:int = 0; i < _selectedSpriteSheet.sprites.length; i++)
			{
				_selectedSpriteSheet.sprites[i].visible = false;
			}
			
			_currSpriteIndex = -1;
			_isPlaying = false;
		}
		
		private function cleanAnimator():void
		{
			resetAnimator();
			
			_viewArea.removeChild(_selectedSpriteSheet.spriteSheet);
			_selectedSpriteSheet = null;
			
			_numSprite = 0;
		}
		
		private function onBrowserButtonClicked(event:TouchEvent):void
		{			
			var action:Touch = event.getTouch(_browserButton, TouchPhase.ENDED);
			
			if (action)
			{
				if (_browserButton.isIn(action.getLocation(this)))
				{
					if (!_resourceFolder)
					{
						_resourceFolder = new File();
					}
					_resourceFolder.addEventListener(Event.SELECT, onResourceFolderSelected);
					_resourceFolder.browseForDirectory("Select Resource Folder");
				}
			}
		}
		
		private function onResourceFolderSelected(event:Event):void
		{	
			_resourceFolder = event.target as File;
			
			if (_resourceFolder.exists)
			{
				var list:Array = _resourceFolder.getDirectoryListing();
				
				if (list && list.length > 0)
				{
					// Reset combo box
					_spriteSheetBox.removeAllItems();
					
					if (_currMode == Mode.IMAGE_MODE)
					{
						ImageMode(_modes[Mode.IMAGE_MODE]).spritesBox.removeAllItems();
					}
					
					for (var i:int = 0; i < list.length; i++)
					{
						if(list[i].name.match(/\.(png)$/i))
						{
							var name:String = File(list[i]).nativePath;
							name = name.substring(name.lastIndexOf("\\") + 1, name.length);
							name = name.substring(0, name.indexOf("."));
							
							_spriteSheetBox.addItem(name);
						}
					}

					_spriteSheetBox.showMessage(_SPRITE_SHEET_BOX_MSG);
				}
			}
		}
		
		private function onTick(event:TimerEvent):void
		{
			var prevIndex:int = _currSpriteIndex;
			_currSpriteIndex++;
			
			if (_currSpriteIndex > _numSprite - 1)
			{
				_currSpriteIndex = 0;
			}
			
			if (prevIndex >= 0)
			{
				_viewArea.getChildByName(_selectedSpriteSheet.sprites[prevIndex].name).visible = false;
			}
			
			_viewArea.addChild(adjustViewingItem(_selectedSpriteSheet.sprites[_currSpriteIndex]));
			_viewArea.getChildByName(_selectedSpriteSheet.sprites[_currSpriteIndex].name).visible = true;
		}
		
		private function onExit(event:Event):void
		{
			// UI
			removeChildren();
			
//			if (_viewArea)
//			{
//				_viewArea.dispose();
//			}
//			_viewArea = null;
//			
//			if (_browserButton)
//			{
//				_browserButton.dispose();
//			}
//			_browserButton = null;
//			
//			if (_spriteSheetBox)
//			{
//				_spriteSheetBox.dispose();
//			}
//			_spriteSheetBox = null;
			
//			if (_radioButtonManager)
//			{
//				_radioButtonManager.dispose();
//			}
			_radioButtonManager = null;
			
//			if (_modes)
//			{
//				for each (var element:Mode in _modes)
//				{
//					element.dispose();
//					element = null;
//				}
//			}
			_modes = null;
			
			_currMode = null;
						
			// Animation
			if (_timer)
			{
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, onTick);
			}
			_timer = null;
			
			_resourceFolder = null;
			
//			if (_selectedSpriteSheet)
//			{
//				_selectedSpriteSheet.dispose();
//			}
			_selectedSpriteSheet = null;
			
			NativeApplication.nativeApplication.removeEventListener(Event.EXITING, onExit);
		}
	}
}