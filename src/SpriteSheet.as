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