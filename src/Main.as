package
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	
	import starling.core.Starling;
	import starling.display.Canvas;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.utils.Align;
	
	public class Main extends Sprite
	{
		private var _resourceFolder:File;
		
		// UI
		private var _viewArea:Canvas;
		private var _browserButton:TextButton;
		private var _radioButtonManager:RadioButtonManager;
		private var _spriteSheetBox:ComboBox;
		private var _modes:Dictionary; // Mode
		
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
			var viewAreaWidth:Number = Starling.current.stage.stageWidth * 0.7;
			var viewAreaHeight:Number = Starling.current.stage.stageHeight * 0.7;
			var viewAreaX:Number = Starling.current.stage.stageWidth * 0.05;
			var viewAreaY:Number = Starling.current.stage.stageHeight / 2 - viewAreaHeight / 2;
			var viewAreaBottom:Number = viewAreaY + viewAreaHeight;
			
			_viewArea = new Canvas();
			_viewArea.x = viewAreaX;
			_viewArea.y = viewAreaY;
			_viewArea.width = viewAreaWidth;
			_viewArea.height = viewAreaHeight;			
			_viewArea.beginFill();
			_viewArea.drawRectangle(0, 0, viewAreaWidth, viewAreaHeight);
			_viewArea.endFill();
			addChild(_viewArea);
			
			var margin:Number = 20;
			var UIAssetX:Number = viewAreaX + viewAreaWidth + margin;
			
			// _browserButton
			_browserButton = new TextButton(UIAssetX, viewAreaY, 200, 30,
				"Select Resource Folder", Align.CENTER, true);
			_browserButton.addEventListener(TouchEvent.TOUCH, onBrowserButtonClicked);
			addChild(_browserButton);
			
			// _radioButtonManager
			var radius:Number = 6;
			
			_radioButtonManager = new RadioButtonManager();
			addChild(_radioButtonManager.addButton(
				UIAssetX, viewAreaBottom - radius * 6, radius, Mode.ANIMATION_MODE, changeMode));
			addChild(_radioButtonManager.addButton(
				UIAssetX, viewAreaBottom - radius * 2, radius, Mode.IMAGE_MODE, changeMode));
			
			// _spriteSheetBox
			_spriteSheetBox = new ComboBox(UIAssetX, viewAreaY + _browserButton.height + margin, 200, 20, loadSpriteSheet);
			addChild(_spriteSheetBox);
			
			setMode(viewAreaX, viewAreaY, viewAreaWidth, viewAreaHeight, UIAssetX);			
		}
		
		private function setMode(
			viewAreaX:Number, viewAreaY:Number, viewAreaWidth:Number, viewAreaHeight:Number, UIAssetX:Number):void
		{
			_modes = new Dictionary();
			
			_modes[Mode.ANIMATION_MODE] = new AnimationMode(Mode.ANIMATION_MODE);
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
				}
			}
		}
		
		private function loadSpriteSheet(name:String):void
		{
			trace(name);
			
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
		
		private function playSpriteSheet(sprites:Vector.<Image>):void
		{
			if (sprites && sprites.length > 0)
			{
				// timer
			}
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
		
		private function onExit(event:Event):void
		{
			// to do
			
			
			
			NativeApplication.nativeApplication.removeEventListener(Event.EXITING, onExit);
		}
	}
}