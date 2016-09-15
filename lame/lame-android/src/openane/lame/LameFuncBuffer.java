package openane.lame;

import com.adobe.fre.*;

public class LameFuncBuffer implements FREFunction {
    @Override
    public FREObject call(FREContext freContext, FREObject[] freObjects) {
        try {
            LameContext context = (LameContext)freContext;
            byte[] data = context.lame.buffer();
            FREByteArray array = FREByteArray.newByteArray();
            array.setProperty("length", FREObject.newObject(data.length));
            array.acquire();
            array.getBytes().put(data);
            array.release();
            return array;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
