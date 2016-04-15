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
			setUI();
						
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExit);
		}
		
		public function changeMode(mode:String):void
		{
			if (_modes && _modes[Mode.ANIMATION_MODE] && _modes[Mode.IMAGE_MODE])
			{
				if (mode == Mode.ANIMATION_MODE)
				{
					Mode(_modes[Mode.IMAGE_MODE]).deactivate();
					Mode(_modes[Mode.ANIMATION_MODE]).activate();
				}
				else if (mode == Mode.IMAGE_MODE)
				{
					Mode(_modes[Mode.ANIMATION_MODE]).deactivate();
					Mode(_modes[Mode.IMAGE_MODE]).activate();
				}
			}
		}
		
		private function loadUIResource():void
		{
			// to do
		}
		
		private function setUI():void
		{
			// _viewArea
			var viewAreaWidth:Number = Starling.current.stage.stageWidth * 0.7;
			var viewAreaHeight:Number = Starling.current.stage.stageHeight * 0.7;
			var viewAreaX:Number = Starling.current.stage.stageWidth * 0.05;
			var viewAreaY:Number = Starling.current.stage.stageHeight / 2 - viewAreaHeight / 2;
			
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
				UIAssetX, viewAreaY + viewAreaHeight - radius * 6, radius, Mode.ANIMATION_MODE, changeMode));
			addChild(_radioButtonManager.addButton(
				UIAssetX, viewAreaY + viewAreaHeight - radius * 2, radius, Mode.IMAGE_MODE, changeMode));
			
			// _spriteSheetBox
			
			
			setMode();			
		}
		
		private function setMode():void
		{
			_modes = new Dictionary();
			
			_modes[Mode.ANIMATION_MODE] = new AnimationMode(Mode.ANIMATION_MODE);
			var animModeUI:Vector.<DisplayObject> = Mode(_modes[Mode.ANIMATION_MODE]).setUI();
			
			if (animModeUI)
			{
				for (var i:int = 0; i < animModeUI.length; i++)
				{
					addChild(animModeUI[i]);
				}
			}
			
			_modes[Mode.IMAGE_MODE] = new AnimationMode(Mode.IMAGE_MODE);
			var imgModeUI:Vector.<DisplayObject> = Mode(_modes[Mode.IMAGE_MODE]).setUI();
			
			if (imgModeUI)
			{
				for (var i:int = 0; i < animModeUI.length; i++)
				{
					addChild(imgModeUI[i]);
				}
			}
			
			changeMode(Mode.ANIMATION_MODE);
		}
		
		private function onBrowserButtonClicked(event:TouchEvent):void
		{			
			var action:Touch = event.getTouch(_browserButton, TouchPhase.ENDED);
			
			if (action)
			{
				if (!_resourceFolder)
				{
					_resourceFolder = new File();
				}
				_resourceFolder.addEventListener(Event.SELECT, onResourceFolderSelected);
				_resourceFolder.browseForDirectory("Select Resource Folder");
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