//
// $id: openaneWeibo.m openane $
//

#import "openaneWeibo.h"

@implementation WeiboConnector

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    @autoreleasepool {
        if ([response isKindOfClass:WBAuthorizeResponse.class])
        {
            WBAuthorizeResponse *token = (WBAuthorizeResponse *)response;
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setValue:[NSNumber numberWithInteger:token.statusCode] forKey:@"status_code"];
            [dict setValue:token.userID forKey:@"uid"];
            [dict setValue:token.accessToken forKey:@"access_token"];
            [dict setValue:[NSNumber numberWithLong:token.expirationDate.timeIntervalSince1970] forKey:@"expires_in"],
            [dict setValue:token.refreshToken forKey:@"refresh_token"];
            FREDispatchStatusEventAsync([self context], FRESTR("authorize"), FRESTR([openaneObjectToJSONString(dict) UTF8String]));
        }
    }
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    @autoreleasepool {
    }
}

@end

void openaneWeiboInitializer(void **extDataToSet, FREContextInitializer *ctxInitializerToSet, FREContextFinalizer *ctxFinalizerToSet)
{
    *extDataToSet = NULL;
    *ctxInitializerToSet = &openaneWeiboContextInitializer;
    *ctxFinalizerToSet = &openaneWeiboContextFinalizer;
}

void openaneWeiboFinalizer(void *extData)
{
}

void openaneWeiboContextInitializer(void *extData, const uint8_t *ctxType, FREContext ctx, uint32_t *numFunctionsToSet, const FRENamedFunction **functionsToSet)
{
    @autoreleasepool {
        static FRENamedFunction funcs[] =
        {
            MAP_FUNCTION("init", openaneWeiboFuncInit, NULL),
            MAP_FUNCTION("authorize", openaneWeiboFuncAuthorize, NULL),
            MAP_FUNCTION("handleOpenURL", openaneWeiboFuncHandleOpenURL, NULL),
        };
        
        *numFunctionsToSet = sizeof(funcs) / sizeof(FRENamedFunction);
        *functionsToSet = funcs;
        
        WeiboConnector *connector = [[WeiboConnector alloc] initWithContext:ctx];
        FRESetContextNativeData(ctx, (void *)CFBridgingRetain(connector));
    }
}

void openaneWeiboContextFinalizer(FREContext ctx)
{
    @autoreleasepool {
        WeiboConnector* connector = openaneWeiboContextNativeData(ctx);
        if (connector != NULL)
        {
            CFBridgingRelease((__bridge CFTypeRef)connector);
            FRESetContextNativeData(ctx, NULL);
        }
    }
}

WeiboConnector *openaneWeiboContextNativeData(FREContext ctx)
{
    void *ptr = NULL;
    if (FREGetContextNativeData(ctx, &ptr) == FRE_OK)
    {
        return (__bridge WeiboConnector *)ptr;
    }
    else
    {
        FREPrint("native data is NULL");
        return NULL;
    }
}

ANE_FUNCTION(openaneWeiboFuncInit)
{
    @autoreleasepool {
        WeiboConnector *connector = openaneWeiboContextNativeData(ctx);
        
        //app key
        NSString *appKey = openaneObjectToString(argv[0]);
        [WeiboSDK registerApp:appKey];
        
        //redirect uri
        NSString *redirectURI = openaneObjectToString(argv[1]);
        connector.redirectURI = redirectURI;
        
        //scope
        NSString *scope = openaneObjectToString(argv[2]);;
        connector.scope = scope;
        
        NSString *msg = [NSString stringWithFormat:@"appKey=%@ redirectURI=%@ scope=%@", appKey, redirectURI, scope];
        FREPrint([msg UTF8String]);
        
        return NULL;
    }
}

ANE_FUNCTION(openaneWeiboFuncAuthorize)
{
    @autoreleasepool {
        WeiboConnector *connector = openaneWeiboContextNativeData(ctx);
        
        WBAuthorizeRequest *req = [WBAuthorizeRequest request];
        req.redirectURI = connector.redirectURI;
        req.scope = connector.scope;
        [WeiboSDK sendRequest:req];
        
        FREPrint("authorize request");
        
        return NULL;
    }
}

ANE_FUNCTION(openaneWeiboFuncHandleOpenURL)
{
    @autoreleasepool {
        WeiboConnector *connector = openaneWeiboContextNativeData(ctx);
        
        //open url
        NSURL *url = [NSURL URLWithString:openaneObjectToString(argv[0])];
        [WeiboSDK handleOpenURL:url delegate:connector];
        
        return NULL;
    }
}