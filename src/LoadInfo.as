package 
{
	import flash.display.BitmapData;

	public class LoadInfo
	{
		private var _type:String;
		private var _path:String;
		private var _name:String;
		private var _spriteSheetBitmapData:BitmapData;
				
		public function LoadInfo(type:String, path:String, name:String)
		{
			_type = type;
			_path = path;
			_name = name;
		}
		
		public function get type():String
		{
			return _type;
		}
		
		public function get path():String
		{
			return _path;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get spriteSheetBitmapData():BitmapData
		{
			return _spriteSheetBitmapData;
		}
		
		public function set spriteSheetBitmapData(bitmapData:BitmapData):void
		{
			_spriteSheetBitmapData = spriteSheetBitmapData;
		}
		
		public function dispose():void
		{
			_type = null;
			_path = null;
			_name = null;
		}
	}
}