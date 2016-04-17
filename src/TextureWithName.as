package
{
	import starling.textures.Texture;

	public class TextureWithName
	{
		private var _texture:Texture;
		private var _name:String;
		
		public function TextureWithName()
		{
			
		}
		
		public function get texture():Texture
		{
			return _texture;
		}
		
		public function set texture(texture:Texture):void
		{
			_texture = texture;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function set name(name:String):void
		{
			_name = name;
		}
	}
}