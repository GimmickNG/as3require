package as3require
{
	/**
	 * Loads an external SWC at the specified paths, in order.
	 * If any error occurs while loading a specified file, then the responder's error handling takes place.
	 * If the responder has its abortOnError set to true, then all subsequent paths are ignored and an error raised.
	 * @param	responder
	 * @param	...paths
	 */
	public function require(responder:IRequireResponder, ...paths):void {
		RequireImpl.createRequire(responder, paths.filter(Utils.nonNull))
	}
}

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.filesystem.File;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import org.as3commons.zip.Zip;
import org.as3commons.zip.ZipErrorEvent;
import as3require.IRequireResponder;
import as3require.RequireResponder;
import as3require.RequireError;

/**
 * ...
 * @author Gimmick
 */
internal final class RequireImpl 
{
	internal static const REQUIRES:Vector.<RequireImpl> = new Vector.<RequireImpl>()
	private var vec_swfLoaders:Vector.<Loader>
	private var cl_loaderContext:LoaderContext;
	public function RequireImpl() 
	{
		cl_loaderContext = new LoaderContext(false, ApplicationDomain.currentDomain, null)
		cl_loaderContext.allowCodeImport = true;
		vec_swfLoaders = new Vector.<Loader>();
	}
	
	public static function getRequires():Vector.<RequireImpl> {
		return REQUIRES
	}
	
	public static function createRequire(responder:IRequireResponder, paths:Array):RequireImpl
	{
		var requirer:RequireImpl = new RequireImpl()
		
		REQUIRES.push(requirer)
		requirer.require(responder, paths)
		
		return requirer
	}
	
	private function loadSWCData(responder:IRequireResponder, file:File):void
	{
		var numItems:uint;
		var data:ByteArray = file.data
		function onError(evt:Event):void
		{
			var currTarget:IEventDispatcher = evt.currentTarget as IEventDispatcher
			
			//remove all listeners
			currTarget.removeEventListener(Event.COMPLETE, loadZip)
			currTarget.removeEventListener(Event.COMPLETE, loadSWFInSWC)
			currTarget.removeEventListener(IOErrorEvent.IO_ERROR, onError)
			currTarget.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError)
			
			responder.runError(new RequireError([file]))
		}
		
		function loadZip(evt:Event):void
		{
			var swcNamespace:Namespace = new Namespace("http://www.adobe.com/flash/swccatalog/9")
			default xml namespace = swcNamespace;
			
			var catalogXML:XML = XML(zip.getFileByName("catalog.xml").content);
			var libraryPaths:XMLList = catalogXML..library.@path;
			numItems = libraryPaths.length();
			for each(var path:XML in libraryPaths)
			{
				var loader:Loader = new Loader()
				var librarySWFBytes:ByteArray = zip.getFileByName(path.toString()).content;
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadSWFInSWC)
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError)
				loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError)
				loader.loadBytes(librarySWFBytes, cl_loaderContext)
			}
			zip.close();
		}
		
		function loadSWFInSWC(evt:Event):void
		{
			var targetLoaderInfo:LoaderInfo = evt.currentTarget as LoaderInfo
			targetLoaderInfo.removeEventListener(Event.COMPLETE, loadSWFInSWC)
			targetLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError)
			targetLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError)
			vec_swfLoaders.push((evt.currentTarget as LoaderInfo).loader);	//to prevent GC
			if(--numItems <= 0) {
				responder.runSuccess()
			}
		}
		
		var zip:Zip = new Zip()
		zip.addEventListener(Event.COMPLETE, loadZip)
		zip.addEventListener(IOErrorEvent.IO_ERROR, onError)
		zip.addEventListener(ZipErrorEvent.PARSE_ERROR, onError)
		zip.loadBytes(data)
	}
	
	internal function require(responder:IRequireResponder, paths:Array):void
	{
		if (!(paths && paths.length)) {
			responder.runSuccess()	//end of method, call responder
		}
		else try
		{
			var file:File = File.applicationDirectory.resolvePath(paths[0]);
			var requireNext:Function = bindRequireNext(responder, paths.slice(1));
			var failAll:IRequireResponder = new RequireResponder(requireNext, responder.onError, responder.thisAnchor, responder.abortOnError)
			
			var onError:Function = bindError(failAll, paths.concat(), file);
			var nextRequest:IRequireResponder = new RequireResponder(requireNext, onError, responder.thisAnchor, responder.abortOnError)
			
			file.addEventListener(Event.COMPLETE, bindRequireNextOnComplete(nextRequest, file));
			file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			file.addEventListener(IOErrorEvent.IO_ERROR, onError);
			file.load()
		}
		catch (err:Error) {
			onError.call(responder.thisAnchor)
		}
	}
	
	/**
	 * The following bind* methods are separated out to keep them from being on the heap when not needed.
	 */
	
	private function bindRequireNextOnComplete(responder:IRequireResponder, file:File):Function
	{
		return function loadRequireNextEvt(evt:Event):void
		{
			file.removeEventListener(Event.COMPLETE, loadRequireNextEvt)
			loadSWCData(responder, file)
		}
	}
	
	private function bindRequireNext(responder:IRequireResponder, paths:Array):Function
	{
		return function requireNext():void {
			require(responder, paths);
		}
	}
	
	private function bindError(responder:IRequireResponder, paths:Array, file:File):Function
	{
		return function onError():void
		{
			file.removeEventListener(IOErrorEvent.IO_ERROR, onError)
			file.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError)
			
			if(responder.abortOnError) {
				responder.runError(new RequireError(paths))
			}
			else {
				responder.runSuccess()
			}
		}
	}
}

internal class Utils 
{
	internal static function nonNull(value:Object, index:int, array:Array):Boolean {
		return value != null;
	}
}
