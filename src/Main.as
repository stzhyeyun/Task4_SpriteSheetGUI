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
		private const _delay:Number = 1500;
		
		// UI
		private var _viewArea:Canvas;
		private var _browserButton:TextButton;
		private var _radioButtonManager:RadioButtonManager;
		private var _spriteSheetBox:ComboBox;
		private var _modes:Dictionary; // Mode
		
		// Animation -> 별도 클래스로 구성?
		private var _timer:Timer;
		private var _resourceFolder:File;
		private var _selectedSpriteSheet:SpriteSheet;
		private var _numSprite:int;
		private var _currSpriteIndex:int = -1;
		private var _isPlaying:Boolean = false;
		private var _isLooped:Boolean = false;
		private var _actualViewAreaWidth:Number;
		private var _actualViewAreaHeight:Number;
		
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
				Starling.current.stage.stageWidth * 0.7,
				Starling.current.stage.stageHeight * 0.7);
			_viewArea.endFill();
			_viewArea.x = Starling.current.stage.stageWidth * 0.05;
			_viewArea.y = (Starling.current.stage.stageHeight / 2) - (_viewArea.height / 2);
			addChild(_viewArea);
			
			var viewAreaMargin:Number = 150;
			_actualViewAreaWidth = _viewArea.width - viewAreaMargin;
			_actualViewAreaHeight = _viewArea.height - viewAreaMargin;
			
			var UIAssetMargin:Number = 20;
			var UIAssetX:Number = _viewArea.x + _viewArea.width + UIAssetMargin;
			
			// _browserButton
			_browserButton = new TextButton(UIAssetX, _viewArea.y, 200, 30,
				"Select Resource Folder", Align.CENTER, true);
			_browserButton.addEventListener(TouchEvent.TOUCH, onBrowserButtonClicked);
			addChild(_browserButton);
			
			// _radioButtonManager
			var radius:Number = 6;
			var viewAreaBottom:Number = _viewArea.y + _viewArea.height;
			
			_radioButtonManager = new RadioButtonManager();
			addChild(_radioButtonManager.addButton(
				UIAssetX, viewAreaBottom - radius * 6, radius, Mode.ANIMATION_MODE, changeMode));
			addChild(_radioButtonManager.addButton(
				UIAssetX, viewAreaBottom - radius * 2, radius, Mode.IMAGE_MODE, changeMode));
			
			// _spriteSheetBox
			_spriteSheetBox = new ComboBox(UIAssetX, _viewArea.y + _browserButton.height + UIAssetMargin, 200, 20, loadSpriteSheet);
			addChild(_spriteSheetBox);
			
			setMode(_viewArea.x, _viewArea.y, _viewArea.width, _viewArea.height, UIAssetX);			
		}
		
		private function setMode(
			viewAreaX:Number, viewAreaY:Number, viewAreaWidth:Number, viewAreaHeight:Number, UIAssetX:Number):void
		{
			_modes = new Dictionary();
			
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
			
			_modes[Mode.IMAGE_MODE] = new ImageMode(Mode.IMAGE_MODE);
			var imgModeUI:Vector.<DisplayObject> =
				_modes[Mode.IMAGE_MODE].setUI(viewAreaX, viewAreaY, viewAreaWidth, viewAreaHeight, UIAssetX);
			
			if (imgModeUI)
			{
				for (var i:int = 0; i < animModeUI.length; i++)
				{
					addChild(imgModeUI[i]);
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
				}
				else if (mode == Mode.IMAGE_MODE)
				{
					_modes[Mode.ANIMATION_MODE].deactivate();
					_modes[Mode.IMAGE_MODE].activate();
					
					// clear view area
				}
			}
		}
		
		private function loadSpriteSheet(name:String):void
		{
			InputManager.getInstance().loadRequest(
				ResourceType.SPRITE_SHEET, _resourceFolder, name,
				showSpriteSheet, true);
		}
		
		private function showSpriteSheet(contents:SpriteSheet):void
		{
			if (contents)
			{
				_selectedSpriteSheet = contents;
				_numSprite = _selectedSpriteSheet.sprites.length;

				_viewArea.addChild(adjustViewingItem(_selectedSpriteSheet.spriteSheet));
			}
		}
		
		private function playSpriteSheet():void
		{
			if (!_selectedSpriteSheet)
			{
				return;
			}
				
			if (!_timer)
			{
				_timer = new Timer(_delay);
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
			_spriteSheetBox.removeAllItems();
			
			// @InputManager
			InputManager.getInstance().releaseRequest(name);
		}
		
		private function adjustViewingItem(item:DisplayObject):DisplayObject
		{
			var scale:Number;
			if (item.width > _actualViewAreaWidth)
			{
				scale = _actualViewAreaWidth / item.width; 
				item.scale = scale;
			}
			else if (item.height > _actualViewAreaHeight)
			{
				scale = _actualViewAreaHeight / item.height;
				item.scale = scale;
			}
			
			item.x = (_viewArea.width / 2) - (item.width / 2);
			item.y = (_viewArea.height / 2) - (item.height / 2);
			
			return item;
		}
		
		private function resetAnimator():void
		{
			if (_timer)
			{
				_timer.stop();
				_timer.reset();
			}
			
			_viewArea.getChildByName(_selectedSpriteSheet.spriteSheet.name).visible = true;
			
			for (var i:int = 0; i < _selectedSpriteSheet.sprites.length; i++)
			{
				var child:DisplayObject = _viewArea.removeChild(_selectedSpriteSheet.sprites[i]);
				
				if (child)
				{
					child.visible = false;
				}
			}
			
			_currSpriteIndex = -1;
			_isPlaying = false;
			_isLooped = false;
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

					_spriteSheetBox.showMessage("Select Sprite Sheet");
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
				_isLooped = true;
			}
			
			if (prevIndex >= 0)
			{
				_viewArea.getChildByName(_selectedSpriteSheet.sprites[prevIndex].name).visible = false;
			}
			
			if (!_isLooped)
			{
				_viewArea.addChild(adjustViewingItem(_selectedSpriteSheet.sprites[_currSpriteIndex]));
			}			
			_viewArea.getChildByName(_selectedSpriteSheet.sprites[_currSpriteIndex].name).visible = true;
		}
		
		private function onExit(event:Event):void
		{
			// to do
			
			
			
			NativeApplication.nativeApplication.removeEventListener(Event.EXITING, onExit);
		}
	}
}