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
		
		public function changeMode(mode:String):void
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
		
		private function setUI():void
		{
			// _viewArea
			var viewAreaWidth:Number = Starling.current.stage.stageWidth * 0.7;
			var viewAreaHeight:Number = Starling.current.stage.stageHeight * 0.7;
			var viewAreaX:Number = Starling.current.stage.stageWidth * 0.05;
			var viewAreaY:Number = Starling.current.stage.stageHeight / 2 - viewAreaHeight / 2;
			var viewAreaBottom:Number = viewAreaY + viewAreaHeight;
			
			_viewArea = new Canvas();
			_viewArea.beginFill();
			_viewArea.drawRectangle(viewAreaX, viewAreaY, viewAreaWidth, viewAreaHeight);
			_viewArea.endFill();
			addChild(_viewArea);
			
			var UIAssetX:Number = viewAreaX + viewAreaWidth + 20;
			
			// _browserButton
			_browserButton = new TextButton(UIAssetX, viewAreaY, 200, 30, "Select Resource Folder");
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
		
		private function showSpriteSheet(spriteSheet:Image):void
		{
			if (spriteSheet)
			{
				spriteSheet.visible = true;
				addChild(spriteSheet);
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
		}
		
		private function onExit(event:Event):void
		{
			// to do
			
			
			
			NativeApplication.nativeApplication.removeEventListener(Event.EXITING, onExit);
		}
	}
}