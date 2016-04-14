package
{
	import flash.display.Sprite;
	import flash.display.StageAlign; 
	import flash.display.StageScaleMode;
	
	import starling.core.Starling;
	
	[SWF(width="1280", height="720", frameRate="60", backgroundColor="#e6e6e6")] // Light gray
	
	public class GUI extends Sprite
	{
		private var _main:Starling;
		
		public function GUI()
		{
//			stage.scaleMode = StageScaleMode.NO_SCALE;
//			stage.align = StageAlign.TOP_LEFT;
			
			_main = new Starling(Main, stage);
			_main.start();
			_main.showStats = true;
		}
	}
}