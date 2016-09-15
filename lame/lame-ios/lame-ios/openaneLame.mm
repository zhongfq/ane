//
// $id: openaneLame.m openane $
//

#import "openaneLame.h"

#define ANE_FUNCTION(f) static FREObject (f)(FREContext ctx, void *data, uint32_t argc, FREObject argv[])
#define MAP_FUNCTION(fn, f, data) {(const uint8_t *)(fn), (data), &(f)}
#define FRESTR(s) ((const uint8_t *)(s))
#define FREPrint(s) FREDispatchStatusEventAsync(ctx, FRESTR("print"), FRESTR(s))

@implementation LameConnector

- (id)initWithContext:(FREContext)ctx
{
    if ((self = [super init]) != nil)
    {
        _context = ctx;
    }
    
    return self;
}

@end

static LameConnector* openaneLameContextNativeData(FREContext ctx)
{
    void *prt = nil;
    if (FREGetContextNativeData(ctx, &prt) == FRE_OK)
    {
        return (__bridge LameConnector *)prt;
    }
    else
    {
        FREPrint("native data is nil");
        return nil;
    }
}

ANE_FUNCTION(openaneLameFuncUpdate)
{
    @autoreleasepool {
        LameConnector *connector = openaneLameContextNativeData(ctx);
        if (connector != nil && connector.lame != nil) {
            FREByteArray array;
            FREAcquireByteArray(argv[0], &array);
            buffer_t *buf = (buffer_t *)malloc(sizeof(*buf));
            buf->pos = 0;
            buf->capacity = array.length;
            buf->data = (char *)malloc(array.length);
            memcpy(buf->data, (const void *)array.bytes, array.length);
            connector.lame->push(buf);
            FREReleaseByteArray(argv[0]);
        }
        return nil;
    }
}

ANE_FUNCTION(openaneLameFuncBuffer)
{
    @autoreleasepool {
        LameConnector *connector = openaneLameContextNativeData(ctx);
        if (connector != nil && connector.lame != nil) {
            connector.lame->flush();
            buffer_t *buf = connector.lame->buffer();
            FREObject obj = NULL, length = NULL;
            FREByteArray array;
            FRENewObject((const uint8_t *)"flash.utils.ByteArray", 0, nullptr, &obj, nullptr);
            FRENewObjectFromUint32((uint32_t)buf->pos, &length);
            FRESetObjectProperty(obj, (const uint8_t *)"length", length, nullptr);
            FREAcquireByteArray(obj, &array);
            memcpy(array.bytes, buf->data, buf->pos);
            FREReleaseByteArray(obj);
            return obj;
        }
        return nil;
    }
}

ANE_FUNCTION(openaneLameFuncDispose)
{
    @autoreleasepool {
        LameConnector *connector = openaneLameContextNativeData(ctx);
        if (connector != nil && connector.lame != nil) {
            delete connector.lame;
            connector.lame = nil;
        }
        return nil;
    }
}

static void openaneLameContextInitializer(void *extData, const uint8_t *ctxType, FREContext ctx, uint32_t *numFunctionsToSet, const FRENamedFunction **functionsToSet)
{
    @autoreleasepool {
        static FRENamedFunction funcs[] =
        {
            MAP_FUNCTION("update", openaneLameFuncUpdate, nil),
            MAP_FUNCTION("buffer", openaneLameFuncBuffer, nil),
            MAP_FUNCTION("dispose", openaneLameFuncDispose, nil),
        };
        
        *numFunctionsToSet = sizeof(funcs) / sizeof(FRENamedFunction);
        *functionsToSet = funcs;
        
        LameConnector *connector = [[LameConnector alloc] initWithContext:ctx];
        connector.lame = new lamewrapper();
        FRESetContextNativeData(ctx, (void *)CFBridgingRetain(connector));
    }
}

static void openaneLameContextFinalizer(FREContext ctx)
{
    @autoreleasepool {
        LameConnector *connector = openaneLameContextNativeData(ctx);
        if (connector != nil)
        {
            if (connector.lame != nil) {
                delete connector.lame;
                connector.lame = nil;
            }
            CFBridgingRelease((__bridge CFTypeRef)connector);
            FRESetContextNativeData(ctx, nil);
        }
    }
}

void openaneLameInitializer(void **extDataToSet, FREContextInitializer *ctxInitializerToSet, FREContextFinalizer *ctxFinalizerToSet)
{
    *extDataToSet = nil;
    *ctxInitializerToSet = &openaneLameContextInitializer;
    *ctxFinalizerToSet = &openaneLameContextFinalizer;
}

void openaneLameFinalizer(void *extData)
{
    
}