package openane.lame;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class LameFuncDispose implements FREFunction {
    @Override
    public FREObject call(FREContext freContext, FREObject[] freObjects) {
        LameContext context = (LameContext)freContext;
        context.lame.dispose();
        return null;
    }
}
