package openane.lame {

import flash.desktop.NativeApplication;
import flash.events.EventDispatcher;
import flash.events.InvokeEvent;
import flash.events.StatusEvent;
import flash.external.ExtensionContext;
import flash.system.Capabilities;
import flash.utils.ByteArray;
import flash.utils.getQualifiedClassName;

public class Lame extends EventDispatcher {
    private var _context:ExtensionContext;

    public function Lame() {
        if (Capabilities.os.search(/Linux|iPhone/) >= 0) {
            _context = ExtensionContext.createExtensionContext("openane.Lame", "");
            _context.addEventListener(StatusEvent.STATUS, statusHandler);
        } else {
            print("unsupported platform '%s'", Capabilities.os);
        }
    }

    private function print(...args):void {
        trace("[Lame] " + format.apply(null, args));
    }

    private function statusHandler(event:StatusEvent):void {
        switch (event.code) {
            case "print":
                print("%s", event.level);
                break;
        }
    }

    public function update(data:ByteArray):void {
        if (_context) {
            data.position = 0;
            _context.call("update", data, data.length);
        }
    }

    public function buffer():ByteArray {
        if (_context) {
            var bytes:ByteArray = _context.call("buffer") as ByteArray;
            return bytes || new ByteArray();
        }

        return new ByteArray();
    }

    public function dispose():void {
        if (_context) {
            _context.call("dispose");
            _context.dispose();
            _context = null;
        }
    }
}
}

internal function format(fmt:String, ...args):String {
    var buffer:Vector.<String> = new Vector.<String>();

    var len:int = fmt.length;
    var start:int = 0;
    while (true) {
        var idx:int = fmt.indexOf("%", start);
        if (idx >= 0) {
            buffer.push(fmt.substring(start, idx));
            if (idx < len - 1) {
                var f:String = fmt.charAt(idx + 1);
                if (f == '%') {
                    buffer.push('%');
                } else if (f == 's') {
                    if (args.length > 0) {
                        buffer.push(String(args.shift()));
                    } else {
                        trace("more '%' conversions than data arguments: " + fmt);
                        break;
                    }
                } else {
                    trace("incomplete format specifier: " + fmt);
                }

                start = idx + 2;
            } else {
                trace("incomplete format specifier: " + fmt);
                break;
            }
        } else {
            buffer.push(fmt.substring(start, len));
            break;
        }
    }

    if (args.length > 0) {
        trace(args.length + " data arguments not used: " + fmt);
    }

    return buffer.join("");
}