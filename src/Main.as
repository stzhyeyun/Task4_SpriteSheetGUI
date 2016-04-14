package
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	
	import starling.display.Sprite;
	
	public class Main extends Sprite
	{
		public function Main()
		{
			// UI 컴포넌츠 세팅
		
			
			
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExit);
		}
		
		private function onExit(event:Event):void
		{
			// to do
			
		}
	}
}