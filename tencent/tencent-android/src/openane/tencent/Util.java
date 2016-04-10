package openane.tencent;

import com.adobe.fre.FREObject;

public class Util {
    public static String objectToString(FREObject obj) {
        try {
            return obj.getAsString();
        } catch (Exception e) {
            return null;
        }
    }
}
