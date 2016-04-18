package
{
	import starling.display.Image;

	public class SpriteSheet
	{
		private var _spriteSheet:Image;
		private var _sprites:Vector.<Image>;
		
		public function SpriteSheet()
		{
			
		}
		
		public function find(name:String):Image
		{
			if (_sprites && _sprites.length > 0)
			{
				for (var i:int = 0; i < _sprites.length; i++)
				{
					if (_sprites[i].name == name)
					{
						return _sprites[i];
					}
				}
			}
			
			return null;
		}
		
		public function getIndex(name:String):int
		{
			if (_sprites && _sprites.length > 0)
			{
				for (var i:int = 0; i < _sprites.length; i++)
				{
					if (_sprites[i].name == name)
					{
						return i;
					}
				}
			}
			
			return -1;
		}
		
		public function get spriteSheet():Image
		{
			return _spriteSheet;
		}
		
		public function set spriteSheet(spriteSheet:Image):void
		{
			_spriteSheet = spriteSheet;
		}
		
		public function get sprites():Vector.<Image>
		{
			return _sprites;
		}
		
		public function set sprites(sprites:Vector.<Image>):void
		{
			_sprites = sprites;
		}
		
		public function dispose():void
		{
			if (_spriteSheet)
			{
				_spriteSheet.dispose();
			}
			_spriteSheet = null;
			
			if (_sprites && _sprites.length > 0)
			{
				for (var i:int = 0; i < _sprites.length; i++)
				{
					_sprites[i].dispose();
					_sprites[i] = null;
				}
			}
			_sprites = null;
		}
	}
}