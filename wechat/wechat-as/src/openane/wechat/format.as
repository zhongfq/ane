package openane.wechat {

public function format(fmt:String, ...args):String {
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
}
