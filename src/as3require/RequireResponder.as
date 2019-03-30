package as3require 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * ...
	 * @author Gimmick
	 */
	public class RequireResponder implements IRequireResponder
	{
		private var fn_onError:Function
		private var fn_onSuccess:Function
		private var b_abortOnError:Boolean
		private var obj_thisAnchor:Object
		public function RequireResponder(onSuccess:Function, onError:Function = null, thisAnchor:Object = null, abortOnError:Boolean = true)
		{
			b_abortOnError = abortOnError;
			obj_thisAnchor = thisAnchor;
			fn_onSuccess = onSuccess;
			fn_onError = onError;
		}
		
		/* INTERFACE IRequireResponder */
		public function runSuccess():void
		{
			if (onSuccess != null) {
				onSuccess.call(thisAnchor)
			}
		}
		
		public function runError(error:RequireError):void 
		{
			if (onError != null) {
				onError.call(thisAnchor, error)
			}
		}
		
		/* INTERFACE IRequireResponder */
		
		public function get abortOnError():Boolean {
			return b_abortOnError;
		}
		
		public function get onError():Function {
			return fn_onError;
		}
		
		public function get onSuccess():Function {
			return fn_onSuccess;
		}
		
		public function get thisAnchor():Object {
			return obj_thisAnchor;
		}
		
	}

}