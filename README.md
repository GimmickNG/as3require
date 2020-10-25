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
* **This does not work for native extensions.** Only SWCs can be loaded via this method.
* You **will** need to create a separate document class which loads all the SWCs first, and add the actual main class as a child after all loading has occurred.
  * This is because VerifyErrors may occur if Flash so much as _sees_ an import statement for a library class it hasn't loaded yet.
* Unpack and repack an SWC with `store` compression if it fails to load.
* If you've tried all the above - creating a preloader, repacking SWCs, etc. - and VerifyErrors still appear regardless of _when_ the main class is loaded - it's probably not going to work for that project.
* Also, while debugging (on Windows; it is unknown if this occurs on other operating systems) if the application stops responding, try shaking its window. This usually only happens in debug mode, although it may also happen if the window is initially invisible in Release mode.
* **Load order matters in release mode** - `require` will completely fail if the first SWC loaded does not have a Main symbol - that is, if in SWC Explorer (in FlashDevelop) there's no Symbol like `_<long random sequence>_flash_display_Sprite` then it's going to show neither a success nor a failure message. This probably has something to do with the `ApplicationDomain` being used; a workaround is to load a normal SWC with such a symbol (SWCs compiled with Flash CC usually work) and load the required SWCs after that. 
  * SWCs created with the FlashDevelop `swcbuild` extension do not have such symbols included, and so need to be loaded last.
