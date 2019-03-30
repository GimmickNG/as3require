package as3require 
{
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public interface IRequireResponder 
	{
		function get abortOnError():Boolean
		function get onError():Function
		function get onSuccess():Function
		function get thisAnchor():Object
		
		//convenience methods
		function runSuccess():void
		//convenience methods
		function runError(error:RequireError):void
	}
	
}