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
			// UI 에셋 로딩
			InputManager.getInstance().loadRequest(
				ResourceType.UI_ASSET,
				File.applicationDirectory.resolvePath("Resources"), "icons",
				onUIAssetLoaded, true);
						
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExit);
		}
		
		/**
		 * AnimationMode와 ImageMode를 세팅합니다. 
		 * @param viewAreaX _viewArea의 x 좌표입니다.
		 * @param viewAreaY _viewArea의 y 좌표입니다.
		 * @param viewAreaWidth _viewArea의 너비입니다.
		 * @param viewAreaHeight _viewArea의 높이입니다.
		 * @param UIAssetX _viewArea 우측에 위치하는 UI 에셋의 x 좌표입니다.
		 * 
		 */
		private function setMode(
			viewAreaX:Number, viewAreaY:Number, viewAreaWidth:Number, viewAreaHeight:Number, UIAssetX:Number):void
		{
			_modes = new Dictionary();
			
			// Image Mode
			_modes[Mode.IMAGE_MODE] = new ImageMode(Mode.IMAGE_MODE, onPrevButtonClicked, onNextButtonClicked);
			var imgModeUI:Vector.<DisplayObject> =
				_modes[Mode.IMAGE_MODE].setUI(viewAreaX, viewAreaY, viewAreaWidth, viewAreaHeight, UIAssetX, onSpriteSelected);
			
			if (imgModeUI)
			{
				for (var i:int = 0; i < imgModeUI.length; i++)
				{
					addChild(imgModeUI[i]);
				}
			}
			
			// Animation Mode
			_modes[Mode.ANIMATION_MODE] = new AnimationMode(
				Mode.ANIMATION_MODE, onPlayButtonClicked, onStopButtonClicked, onReleaseButtonClicked);
			var animModeUI:Vector.<DisplayObject> =
				_modes[Mode.ANIMATION_MODE].setUI(viewAreaX, viewAreaY, viewAreaWidth, viewAreaHeight, UIAssetX);
			
			if (animModeUI)
			{
				for (var i:int = 0; i < animModeUI.length; i++)
				{
					addChild(animModeUI[i]);
				}
			}
			
			onModeSelected(Mode.ANIMATION_MODE);
		}
		
		/**
		 * 실질적 View 영역보다 큰 스프라이트의 크기를 조정합니다. 
		 * @param item 크기를 조정하고자 하는 DisplayObject입니다.
		 * @return 크기가 조정된 DisplayObject를 반환합니다.
		 * 
		 */
		private function adjustViewingItem(item:DisplayObject):DisplayObject // 개선 필요
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
		
		/**
		 * 애니메이션 관련 객체를 초기화합니다. 
		 * 
		 */
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
		
		/**
		 * 애니메이션 관련 객체를 제거합니다.
		 * 
		 */
		private function cleanAnimator():void
		{
			resetAnimator();
			
			_viewArea.removeChild(_selectedSpriteSheet.spriteSheet);
			_selectedSpriteSheet = null;
			
			_numSprite = 0;
		}
		
		/**
		 * UI 에셋 리소스의 로딩이 완료되면 에셋을 생성하고 세팅합니다. 
		 * call by InputManager
		 */
		private function onUIAssetLoaded():void
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
				COMBO_BOX_WIDHT, COMBO_BOX_HEIGHT, "Sprite Sheet", onSpriteSheetSelected);
			addChild(_spriteSheetBox);
			
			// _radioButtonManager
			var viewAreaBottom:Number = _viewArea.y + _viewArea.height;
			
			_radioButtonManager = new RadioButtonManager();
			addChild(_radioButtonManager.addButton(
				UIAssetX, viewAreaBottom - _RADIO_BTN_RADIUS * 6, _RADIO_BTN_RADIUS, Mode.ANIMATION_MODE, onModeSelected));
			addChild(_radioButtonManager.addButton(
				UIAssetX, viewAreaBottom - _RADIO_BTN_RADIUS * 2, _RADIO_BTN_RADIUS, Mode.IMAGE_MODE, onModeSelected));
			
			// Mode
			setMode(_viewArea.x, _viewArea.y, _viewArea.width, _viewArea.height, UIAssetX);			
		}
		
		/**
		 * 모드를 변환합니다. 
		 * @param mode 변환할 모드의 이름입니다.
		 * call by RadioButton / _radioButtonManager
		 */
		private function onModeSelected(mode:String):void
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
		
		/**
		 * 새롭게 선택된 스프라이트 시트를 로드합니다. 
		 * @param currItemName 불러오고자 하는 스프라이트 시트의 이름입니다.
		 * @param prevItemName 현재 출력 중인 스프라이트 시트의 이름입니다. 출력 중인 스프라이트 시트가 없을 경무 null입니다.
		 * call by _spriteSheetBox
		 */
		private function onSpriteSheetSelected(currItemName:String, prevItemName:String):void
		{
			resetAnimator();
			
			InputManager.getInstance().loadRequest(
				ResourceType.SPRITE_SHEET, _resourceFolder, currItemName,
				onSpriteSheetLoaded, true);
		}
		
		/**
		 * 스프라이트 시트의 로딩이 완료되면 시트를 View 영역에 출력합니다. 이미지 모드일 경우 시트가 포함하는 스프라이트 목록을 콤보 박스에 등록합니다. 
		 * @param contents 로드된 스프라이트 시트입니다.
		 * call by InputManager
		 */
		private function onSpriteSheetLoaded(contents:SpriteSheet):void
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
		
		/**
		 * 현재 선택된 스프라이트 시트를 재생합니다.
		 * call by AnimationMode
		 */
		private function onPlayButtonClicked():void
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
		
		/**
		 * 스프라이트 재생을 정지하고 선택된 스트라이트 시트를 출력합니다. 
		 * call by AnimationMode
		 */
		private function onStopButtonClicked():void
		{
			if (_isPlaying)
			{
				resetAnimator();
				_viewArea.getChildByName(_selectedSpriteSheet.spriteSheet.name).visible = true;
			}
		}
		
		/**
		 * 선택된 스프라이트 시트를 메모리(InputManager)에서 제거합니다. 
		 * call by AnimationMode
		 */
		private function onReleaseButtonClicked():void
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
		
		/**
		 * 콤보 박스에서 선택한 스프라이트를 View 영역에 출력합니다. 
		 * @param currItemName 출력하고자 하는 스프라이트의 이름입니다.
		 * @param prevItemName 현재 출력 중인 스프라이트의 이릅입니다. 출력 중인 스프라이트가 없을 경우 null입니다.
		 * call by ComboBox (ImageMode)
		 */
		private function onSpriteSelected(currItemName:String, prevItemName:String):void
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
		
		/**
		 * 현재 출력된 스프라이트의 이전 스프라이트를 출력합니다. 맨 처음 스프라이트일 경우 마지막 스프라이트를 출력합니다.
		 * call by ImageMode
		 */
		private function onPrevButtonClicked():void
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
		
		/**
		 * 현재 출력된 스프라이트의 다음 스프라이트를 출력합니다. 마지막 스프라이트일 경우 맨 처음 스프라이트를 출력합니다.
		 * call by ImageMode
		 */
		private function onNextButtonClicked():void
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
		
		/**
		 * _browserButton 클릭 시 리소스 폴더 지정을 위한 탐색기를 엽니다.
		 * @param event 터치 이벤트입니다.
		 * 
		 */
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
		
		/**
		 * 탐색기에서 리소스 폴더를 선택하면 그 경로를 저장하고 해당 폴더에 존재하는 PNG 파일의 리스트를 _spriteSheetBox에 출력합니다.
		 * @param event 선택 이벤트입니다.
		 * 
		 */
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
		
		/**
		 * 애니메이션 재생 시 설정한 딜레이마다 호출되는 함수입니다. 현재 출력 중인 스프라이트를 숨기고 다음 인덱스의 스프라이트를 보이게 합니다. 
		 * @param event 타이머 이벤트입니다.
		 * 
		 */
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