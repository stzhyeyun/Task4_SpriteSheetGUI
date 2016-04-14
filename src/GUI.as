package
{
	import flash.display.Sprite;
	
	import starling.core.Starling;
	
	[SWF(width="1280", height="720", frameRate="60", backgroundColor="#e6e6e6")] // Light gray
	
	public class GUI extends Sprite
	{
		private var _main:Starling;
		
		public function GUI()
		{
			_main = new Starling(Main, stage);
			_main.start();
			_main.showStats = true;
		}
	}
}