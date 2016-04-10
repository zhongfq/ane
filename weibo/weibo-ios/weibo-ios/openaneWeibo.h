//
// $id: openaneWeibo.h openane $
//

#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"
#import "WeiboSDK.h"
#import "openane.h"

@interface WeiboConnector : Connector<WeiboSDKDelegate>

@property(readwrite, strong, nonatomic) NSString *redirectURI;
@property(readwrite, strong, nonatomic) NSString *scope;

/* WeiboSDKDelegate */
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request;
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response;

@end

#define DLOG(fmt, ...) OPENANE_LOG(@"openaneWeibo", fmt, ##__VA_ARGS__)

void openaneWeiboInitializer(void **extDataToSet, FREContextInitializer *ctxInitializerToSet, FREContextFinalizer *ctxFinalizerToSet);
void openaneWeiboFinalizer(void *extData);

void openaneWeiboContextInitializer(void *extData, const uint8_t *ctxType, FREContext ctx, uint32_t *numFunctionsToSet, const FRENamedFunction **functionsToSet);
void openaneWeiboContextFinalizer(FREContext ctx);
WeiboConnector *openaneWeiboContextNativeData(FREContext ctx);

ANE_FUNCTION(openaneWeiboFuncInit);
ANE_FUNCTION(openaneWeiboFuncAuthorize);
ANE_FUNCTION(openaneWeiboFuncHandleOpenURL);