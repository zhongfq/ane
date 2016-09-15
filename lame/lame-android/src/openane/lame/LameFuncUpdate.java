package openane.lame;

import com.adobe.fre.FREByteArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

import java.nio.ByteBuffer;

public class LameFuncUpdate implements FREFunction {
    @Override
    public FREObject call(FREContext freContext, FREObject[] args) {
        try {
            LameContext context = (LameContext)freContext;
            FREByteArray array = (FREByteArray) args[0];
            array.acquire();
            ByteBuffer buffer = array.getBytes();
            byte[] bytes = new byte[(int) array.getLength()];
            buffer.get(bytes);
            array.release();
            context.lame.update(bytes, bytes.length);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
