//
// $id: openaneAlipay.m openane $
//

#import "openaneAlipay.h"
#import "DataSigner.h"
#import "DataVerifier.h"
#import <AlipaySDK/AlipaySDK.h>

#define ANE_FUNCTION(f) static FREObject (f)(FREContext ctx, void *data, uint32_t argc, FREObject argv[])
#define MAP_FUNCTION(fn, f, data) {(const uint8_t *)(fn), (data), &(f)}
#define FRESTR(s) ((const uint8_t *)(s))

#define FREPrint(s) FREDispatchStatusEventAsync(ctx, FRESTR("print"), FRESTR(s))
#define UNUSED(e) (void)(e)

@implementation AlipayConnector

- (id)initWithContext:(FREContext)ctx
{
    if ((self = [super init]) != nil)
    {
        _context = ctx;
    }
    
    return self;
}

@end

static NSString *openaneObjectToString(FREObject obj)
{
    const uint8_t *value = nil;
    uint32_t len = 0;
    
    if (FREGetObjectAsUTF8(obj, &len, &value) == FRE_OK)
    {
        return [NSString stringWithUTF8String:(const char *)value];
    }
    else
    {
        return nil;
    }
}

static NSString *openaneObjectToJSONString(NSObject *obj)
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

static AlipayConnector* openaneAlipayContextNativeData(FREContext ctx)
{
    void *prt = nil;
    if (FREGetContextNativeData(ctx, &prt) == FRE_OK)
    {
        return (__bridge AlipayConnector *)prt;
    }
    else
    {
        FREPrint("native data is nil");
        return nil;
    }
}

ANE_FUNCTION(openaneAlipayFuncInit)
{
    @autoreleasepool {
        AlipayConnector *connector = openaneAlipayContextNativeData(ctx);
        connector.appID = openaneObjectToString(argv[0]);
        connector.publicKey = openaneObjectToString(argv[1]);
        connector.privateKey = openaneObjectToString(argv[2]);
        
        NSString *msg = [NSString stringWithFormat:@"init alipay: appid=%@", connector.appID];
        FREPrint([msg UTF8String]);
        
        return nil;
    }
}

static NSDictionary *openaneAlipayAppendVerifyStatus(NSDictionary *dict, NSString *publicKey)
{
    NSMutableDictionary *muteableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    NSString *resultStatus = [dict objectForKey:@"resultStatus"];
    BOOL ok = NO;
    if (publicKey != nil && resultStatus != nil && [resultStatus isEqualToString:@"9000"])
    {
        NSString *result = [dict objectForKey:@"result"];
        NSMutableArray *values = [[NSMutableArray alloc] init];
        NSString *sign = nil;
        NSString *success = nil;
        for (NSString *value in [result componentsSeparatedByString:@"&"]) {
            if ([value hasPrefix:@"sign="])
            {
                NSUInteger start = strlen("sign=\"");
                sign = [value substringWithRange:NSMakeRange(start, value.length - start - 1)];
            }
            else if (![value hasPrefix:@"sign_type="])
            {
                if ([value hasPrefix:@"success="])
                {
                    NSUInteger start = strlen("success=\"");
                    success = [value substringWithRange:NSMakeRange(start, value.length - start - 1)];
                }
                [values addObject:value];
            }
        }
        
        id<DataVerifier> verifier = CreateRSADataVerifier(publicKey);
        if (sign != nil && success != nil && [success isEqualToString:@"true"])
        {
            ok = [verifier verifyString:[values componentsJoinedByString:@"&"] withSign:sign];
        }
    }
    
    if (ok)
    {
        [muteableDict setValue:@"true" forKey:@"verifyStatus"];
    }
    else
    {
        [muteableDict setValue:@"false" forKey:@"verifyStatus"];
    }
    
    return muteableDict;
}

ANE_FUNCTION(openaneAlipayFuncPay)
{
    @autoreleasepool {
        AlipayConnector *connector = openaneAlipayContextNativeData(ctx);
        if (connector.appID == nil)
        {
            FREPrint("app key is not set");
        }
        else if (connector.privateKey == nil || connector.publicKey == nil)
        {
            FREPrint("private key or public key is null or empty");
        }
        else
        {
            NSString *orderInfo = openaneObjectToString(argv[0]);
            id<DataSigner> signer = CreateRSADataSigner(connector.privateKey);
            NSString *signedString = [signer signString:orderInfo];
            if (signedString == nil)
            {
                FREDispatchStatusEventAsync(ctx, FRESTR("print"), FRESTR("sign error"));
            }
            else
            {
                NSString *appID = [NSString stringWithFormat:@"al%@", connector.appID];
                NSString *signedInfo = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"", orderInfo, signedString, @"RSA"];
                
                NSString *msg = [NSString stringWithFormat:@"pay: %@", signedInfo];
                FREPrint([msg UTF8String]);
                
                [[AlipaySDK defaultService] payOrder:signedInfo fromScheme:appID callback:^(NSDictionary *resultDic) {
                    resultDic = openaneAlipayAppendVerifyStatus(resultDic, connector.publicKey);
                    FREDispatchStatusEventAsync(ctx, FRESTR("pay"), FRESTR([openaneObjectToJSONString(resultDic) UTF8String]));
                }];
            }
        }
        return nil;
    }
}

ANE_FUNCTION(openaneAlipayFuncPayWithSignedInfo)
{
    @autoreleasepool {
        AlipayConnector *connector = openaneAlipayContextNativeData(ctx);
        
        if (connector.appID == nil)
        {
            FREPrint("app key is not set");
        }
        else
        {
            NSString *appID = [NSString stringWithFormat:@"al%@", connector.appID];
            NSString *signedInfo = openaneObjectToString(argv[0]);
            
            NSString *msg = [NSString stringWithFormat:@"pay with signed info: %@", signedInfo];
            FREPrint([msg UTF8String]);
            
            [[AlipaySDK defaultService] payOrder:signedInfo fromScheme:appID callback:^(NSDictionary *resultDic) {
                resultDic = openaneAlipayAppendVerifyStatus(resultDic, connector.publicKey);
                FREDispatchStatusEventAsync(ctx, FRESTR("payWithSignedInfo"), FRESTR([openaneObjectToJSONString(resultDic) UTF8String]));
            }];
        }
        
        return nil;
    }
}

ANE_FUNCTION(openaneAlipayFuncHandleOpenURL)
{
    @autoreleasepool {
        AlipayConnector *connector = openaneAlipayContextNativeData(ctx);
        NSURL *url = [NSURL URLWithString:openaneObjectToString(argv[0])];
        if ([url.host isEqualToString:@"safepay"])
        {
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                resultDic = openaneAlipayAppendVerifyStatus(resultDic, connector.publicKey);
                FREDispatchStatusEventAsync(ctx, FRESTR("pay"), FRESTR([openaneObjectToJSONString(resultDic) UTF8String]));
                FREDispatchStatusEventAsync(ctx, FRESTR("payWithSignedInfo"), FRESTR([openaneObjectToJSONString(resultDic) UTF8String]));
            }];
        }
        return nil;
    }
}

static void openaneAlipayContextInitializer(void *extData, const uint8_t *ctxType, FREContext ctx, uint32_t *numFunctionsToSet, const FRENamedFunction **functionsToSet)
{
    @autoreleasepool {
        static FRENamedFunction funcs[] =
        {
            MAP_FUNCTION("init", openaneAlipayFuncInit, nil),
            MAP_FUNCTION("pay", openaneAlipayFuncPay, nil),
            MAP_FUNCTION("payWithSignedInfo", openaneAlipayFuncPayWithSignedInfo, nil),
            MAP_FUNCTION("handleOpenURL", openaneAlipayFuncHandleOpenURL, nil),
        };
        
        *numFunctionsToSet = sizeof(funcs) / sizeof(FRENamedFunction);
        *functionsToSet = funcs;
        
        AlipayConnector *connector = [[AlipayConnector alloc] initWithContext:ctx];
        FRESetContextNativeData(ctx, (void *)CFBridgingRetain(connector));
    }
}

static void openaneAlipayContextFinalizer(FREContext ctx)
{
    @autoreleasepool {
        AlipayConnector *connector = openaneAlipayContextNativeData(ctx);
        if (connector != nil)
        {
            CFBridgingRelease((__bridge CFTypeRef)connector);
            FRESetContextNativeData(ctx, nil);
        }
    }
}

void openaneAlipayInitializer(void **extDataToSet, FREContextInitializer *ctxInitializerToSet, FREContextFinalizer *ctxFinalizerToSet)
{
    *extDataToSet = nil;
    *ctxInitializerToSet = &openaneAlipayContextInitializer;
    *ctxFinalizerToSet = &openaneAlipayContextFinalizer;
}

void openaneAlipayFinalizer(void *extData)
{
    
}