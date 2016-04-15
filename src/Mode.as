package
{
	import starling.display.DisplayObject;

	public class Mode
	{
		public static const ANIMATION_MODE:String = "Animation Mode";
		public static const IMAGE_MODE:String = "Image Mode";
		
		protected var _id:String;
		
		public virtual function Mode()
		{
			
		}
		
		public virtual function setUI():Vector.<DisplayObject>
		{
			return null;
		}
		
		public virtual function activate():void
		{
			
		}
		
		public virtual function deactivate():void
		{
			
		}
		
		public virtual function dispose():void
		{
			_id = null;
		}
	}
}