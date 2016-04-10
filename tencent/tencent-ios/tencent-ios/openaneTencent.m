//
// $id: openaneTencent.m openane $
//

#import "openaneTencent.h"

@implementation TencentConnector

- (void)tencentDidLogin
{
//    if ([self.oauth getUserInfo] == NO)
//    {
//        [self didAuthorize:TencentOAuthStatusFail withAPIResponse:nil];
//    }
    [self didAuthorize:TencentOAuthStatusSuccess withAPIResponse:nil];
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    [self didAuthorize:TencentOAuthStatusCancel withAPIResponse:nil];
}

- (void)tencentDidNotNetWork
{
    [self didAuthorize:TencentOAuthStatusFail withAPIResponse:nil];
}

- (void)getUserInfoResponse:(APIResponse *)response
{
    [self didAuthorize:TencentOAuthStatusSuccess withAPIResponse:response];
}

- (void)didAuthorize:(TencentOAuthStatus)status withAPIResponse:(APIResponse *)response
{
    @autoreleasepool {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:response.jsonResponse];
        [dict setValue:[NSNumber numberWithInt:status] forKey:@"status_code"];
        
        if (status == TencentOAuthStatusSuccess)
        {
            [dict setValue:self.oauth.accessToken forKey:@"access_token"];
            [dict setValue:self.oauth.openId forKey:@"openid"];
            [dict setValue:[NSNumber numberWithDouble:[self.oauth.expirationDate timeIntervalSince1970]] forKey:@"expires_int"];
        }
        
        FREDispatchStatusEventAsync(self.context, FRESTR("authorize"), FRESTR([openaneObjectToJSONString(dict) UTF8String]));
    }
}

@end

void openaneTencentInitializer(void **extDataToSet, FREContextInitializer *ctxInitializerToSet, FREContextFinalizer *ctxFinalizerToSet)
{
    *extDataToSet = NULL;
    *ctxInitializerToSet = &openaneTencentContextInitializer;
    *ctxFinalizerToSet = &openaneTencentContextFinalizer;
}

void openaneTencentFinalizer(void *extData)
{
    
}

void openaneTencentContextInitializer(void *extData, const uint8_t *ctxType, FREContext ctx, uint32_t *numFunctionsToSet, const FRENamedFunction **functionsToSet)
{
    @autoreleasepool {
        static FRENamedFunction func[] = {
            MAP_FUNCTION("init", openaneTencentFuncInit, NULL),
            MAP_FUNCTION("authorize", openaneTencentFuncAuthorize, NULL),
            MAP_FUNCTION("handleOpenURL", openaneTencentFuncHandleOpenURL, NULL),
        };
        
        *numFunctionsToSet = sizeof(func) / sizeof(FRENamedFunction);
        *functionsToSet = func;
        
        TencentConnector *connector = [[TencentConnector alloc] initWithContext:ctx];
        FRESetContextNativeData(ctx, (void *)CFBridgingRetain(connector));
    }
}

void openaneTencentContextFinalizer(FREContext ctx)
{
    @autoreleasepool {
        TencentConnector *connector = openaneTencentContextNativeData(ctx);
        if (connector != NULL)
        {
            CFBridgingRelease((__bridge CFTypeRef)connector);
            FRESetContextNativeData(ctx, NULL);
        }
    }
}

TencentConnector *openaneTencentContextNativeData(FREContext ctx)
{
    void *ptr = NULL;
    if (FREGetContextNativeData(ctx, &ptr) == FRE_OK)
    {
        return (__bridge TencentConnector *)ptr;
    }
    else
    {
        FREPrint("native data is null");
        return NULL;
    }
}

ANE_FUNCTION(openaneTencentFuncInit)
{
    @autoreleasepool {
        TencentConnector *connector = openaneTencentContextNativeData(ctx);
        NSString *appid = openaneObjectToString(argv[0]);
        connector.oauth = [[TencentOAuth alloc] initWithAppId:appid andDelegate:connector];
        
        NSString *msg = [NSString stringWithFormat:@"init tencent oauth: appid=%@", appid];
        FREPrint([msg UTF8String]);
        
        return NULL;
    }
}

ANE_FUNCTION(openaneTencentFuncAuthorize)
{
    @autoreleasepool {
        TencentConnector *connector = openaneTencentContextNativeData(ctx);
        
        if (connector.oauth == NULL)
        {
            FREPrint("sdk not initialized");
            return NULL;
        }
        
        NSArray *permissions = [openaneObjectToString(argv[0]) componentsSeparatedByString:@","];
        [connector.oauth authorize:permissions];
        
        NSString *msg = [NSString stringWithFormat:@"authorize with scope: %@", [permissions componentsJoinedByString:@", "]];
        FREPrint([msg UTF8String]);
        
        return NULL;
    }
}

ANE_FUNCTION(openaneTencentFuncHandleOpenURL)
{
    @autoreleasepool {
        NSURL *url = [NSURL URLWithString:openaneObjectToString(argv[0])];
        [TencentOAuth HandleOpenURL:url];
        return NULL;
    }
}