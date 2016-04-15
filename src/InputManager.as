package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import starling.display.Image;
	import starling.textures.Texture;

	public class InputManager
	{
		public static const UI_RESOURCE:String = "UI Resource";
		public static const SPRITE_SHEET:String = "Sprite Sheet";
		
		private static var _instance:InputManager;
		
		private var _loader:Loader;
		private var _queue:Vector.<LoadInfo>;
		private var _setUI:Function;
		private var _showSpriteSheet:Function;

		private var _UIResources:Dictionary; // Texture
		private var _spriteSheets:Dictionary; // SpriteSheet
		
		public function InputManager()
		{
			_instance = this;
		}
		
		public static function getInstance():InputManager
		{
			if (!_instance)
			{
				_instance = new InputManager();
			} 
			return _instance;
		}
		
		public function dispose():void
		{
			clean();
			
			if (_UIResources)
			{
				for each (var texture:Texture in _UIResources)
				{
					texture.dispose();
					texture = null;
				}
			}
			_UIResources = null;
			
			if (_spriteSheets)
			{
				for each (var spriteSheet:SpriteSheet in _spriteSheets)
				{
					spriteSheet.dispose();
					spriteSheet = null;
				}
			}
			_spriteSheets = null;
			
			_instance = null;
		}
		
		public function getTexture(name:String):Texture
		{
			// to do
			
			return null;
		}
		
		public function getSpriteSheet(name:String):SpriteSheet
		{
			// to do
			
			return null;
		}
		
		public function loadRequest(type:String, path:File, name:String, func:Function, startLoad:Boolean):void
		{
			var png:File = path.resolvePath(name + ".png");
			var xml:File = path.resolvePath(name + ".xml");
			
			if (!png.exists || !xml.exists)
			{
				return;
			}
			
			switch (type)
			{
				case UI_RESOURCE:
				{
					_setUI = func;
				} 
					break;
				
				case SPRITE_SHEET:
				{
					_showSpriteSheet = func;
				} 
					break;
			}
			
			var loadInfo:LoadInfo = new LoadInfo(type, path.nativePath, name);
			
			if (!_queue)
			{
				_queue = new Vector.<LoadInfo>();
			}
			_queue.push(loadInfo);
			
			if (startLoad)
			{
				loadPNG();
			}		
		}
		
		private function loadPNG():void
		{	
			if (_queue && _queue.length > 0)
			{
				if (!_loader)
				{
					_loader = new Loader();
				}
				
				_loader.load(new URLRequest(_queue[0].path + "\\" + _queue[0].name + ".png"));
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteLoadPNG);
			}
		}
		
		private function loadXML():void
		{	
			if (_queue && _queue.length > 0)
			{
				if (!_loader)
				{
					_loader = new Loader();
				}
				
				_loader.load(new URLRequest(_queue[0].path + "\\" + _queue[0].name + ".xml"));
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteLoadXML);
			}
		}
		
		private function onCompleteLoadPNG(event:Event):void
		{
			_queue[0].spriteSheetBitmapData = Bitmap(event.currentTarget.loader.content).bitmapData;
			
			loadXML();
		}
		
		private function onCompleteLoadXML(event:Event):void
		{
			var xml:XML = new XML(event.currentTarget.data);
			
			unpack(xml);
			
			switch (_queue[0].type)
			{
				case UI_RESOURCE:
				{
					_setUI();
				} 
					break;
				
				case SPRITE_SHEET:
				{
					_showSpriteSheet(_spriteSheets[_spriteSheets.length - 1].spriteSheet);
				} 
					break;
			}
			
			_queue[0].dispose();
			_queue[0] = null;
			_queue.shift();
			
			if (_queue.length > 0)
			{
				loadPNG();
			}
			else
			{
				clean();
			}
		}
		
		private function unpack(xml:XML):void
		{
			if (!xml)
			{
				return;
			}
			
			var contents:SpriteSheet = new SpriteSheet();
			
			// Sprite Sheet
			var spriteSheet:Image = new Image(Texture.fromBitmapData(_queue[0].spriteSheetBitmapData));
			spriteSheet.name = xml.child("SpriteSheet")[0].attribute("name");
			contents.spriteSheet = spriteSheet;
			
			// Sprite
			var sprites:Vector.<Image> = new Vector.<Image>();
			for (var i:int = 0; i < xml.child("Sprite").length(); i++)
			{
				var name:String = xml.child("Sprite")[i].attribute("name");
				var x:Number = xml.child("Sprite")[i].attribute("x") as Number;
				var y:Number = xml.child("Sprite")[i].attribute("y") as Number;
				var width:Number = xml.child("Sprite")[i].attribute("width") as Number;
				var height:Number = xml.child("Sprite")[i].attribute("height") as Number;
				var isRotated:Boolean = xml.child("Sprite")[i].attribute("rotated") as Boolean;
				
				var texture:Texture;
				
				if (isRotated)
				{
					var canvas:BitmapData = new BitmapData(height, width);
					
					var mat:Matrix = new Matrix();
					mat.rotate(degreeToRadian(-90));
					mat.translate(x, y + width);
					
					canvas.draw(_queue[0].spriteSheetBitmapData, mat,
						null, null, null, true); // need test
					
					texture = Texture.fromBitmapData(canvas);
				}
				else
				{
					var canvas:BitmapData = new BitmapData(width, height);
					
					canvas.copyPixels(
						_queue[0].spriteSheetBitmapData,
						new Rectangle(x, y, width, height),
						new Point(0, 0));
					
					texture = Texture.fromBitmapData(canvas);
				}
				
				var sprite:Image = new Image(texture);
				sprite.name = name;
				sprites.push(sprite);
			}
			contents.sprites = sprites;
			
			_spriteSheets[contents.spriteSheet.name] = contents;
		}
		
		private function degreeToRadian(degree:Number):Number
		{
			return degree / 180 * Math.PI; 
		}

		private function clean():void
		{
			if (_loader)
			{
				_loader.unload();
			}
			_loader = null;
			
			if (_queue && _queue.length > 0)
			{
				for (var i:int = 0; i < _queue.length; i++)
				{
					_queue[i].dispose();
					_queue[i] = null;
				}
			}
			_queue = null;

			_setUI = null;
			_showSpriteSheet = null;
		}
	}
}

