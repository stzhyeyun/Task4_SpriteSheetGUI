package
{
	public class Mode
	{
		public static const ANIMATION_MODE:String = "Animation Mode";
		public static const IMAGE_MODE:String = "Image Mode";
		
		protected var _id:String;
		
		public virtual function Mode()
		{
			
		}
		
		public virtual function dispose():void
		{
			_id = null;
		}
	}
}