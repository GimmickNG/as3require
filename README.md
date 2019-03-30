# as3require
Dynamic SWC loading at runtime in AS3. Similar to `require` in PHP.

## Requirements
Needs Adobe AIR to work. Does not work for web targets.

Uses the AS3Commons Zip library to extract SWCs.

## Usage
Create a `RequireResponder` object with the `onSuccess`, `onError`, `thisAnchor` and `abortOnError` attributes, and pass that along with the files to load to the `require` function.
For example, to load the following SWC files in the tree structure:

```
root
  lib
    first.swc
    second.swc
    third.swc
  content.swf
```

Where content.swf is the main SWF and Main.as is the document class:

```
package
{
    import as3require.require;
    import as3require.RequireError;
    import as3require.RequireResponder;
    public class Main extends Sprite
    {
        public function Main() {
            require(new RequireResponder(init, throwError, this, true), "lib/first.swc", "lib/second.swc", "lib/third.swc");
        }
        private function init():void {
            //init
        }
        private function throwError(error:RequireError):void {
            throw error;
        }
    }
}
```

## Caveats
* This may or may not work on your project. 
* No explicit guarantees: a smallish AIR app with a few SWCs worked OK, but a larger one with 6+ SWCs did not.
* You **will** need to create a separate document class which loads all the SWCs first and adds the actual main class as a child after all loading has occurred.
* Some SWCs may not be parsed properly even if they're valid archives. If this happens, unpack and repack it again with a different compression algorithm; if you don't mind space, `Store` works almost all the time.
* This is because VerifyErrors may occur if Flash so much as _sees_ an import statement for a library class it hasn't loaded yet.
  * As a result, if you've tried all the above - creating a preloader, etc. - and VerifyErrors still appear regardless of _when_ the main class is loaded - it's probably not going to work for that project.
* Also, while debugging, if it says "Program not responding", try shaking the application window. This usually only happens in debug mode, although it may also happen if the window is initially invisible in Release mode.
