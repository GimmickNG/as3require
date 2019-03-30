package as3require 
{
	/**
	 * ...
	 * @author Gimmick
	 */
	public class RequireError extends Error
	{
		private var arr_errorPaths:Array;
		public function RequireError(errorPaths:Array)
		{
			arr_errorPaths = errorPaths
			super("Failed to load the following libraries:\n" + errorPaths.join("\n"), 46450)	//arbitrary
		}
		
		public function get errorPaths():Array {
			return arr_errorPaths;
		}
	}

}