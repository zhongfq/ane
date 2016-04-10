//
// $id: openaneWeChat.h openane $
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "openane.h"
#import "WXApi.h"

@interface WeChatConnector : Connector<WXApiDelegate>

@property(readwrite, strong, nonatomic) NSString *appID;
@property(readwrite, strong, nonatomic) NSString *appSecret;

// wechat sdk
- (void)onReq:(BaseReq*)req;
- (void)onResp:(BaseResp*)resp;

@end

#define DLOG(fmt, ...) OPENANE_LOG(@"openaneWeChat", fmt, ##__VA_ARGS__)

void openaneWeChatInitializer(void **extDataToSet, FREContextInitializer *ctxInitializerToSet, FREContextFinalizer *ctxFinalizerToSet);
void openaneWeChatFinalizer(void *extData);

void openaneWeChatContextInitializer(void *extData, const uint8_t *ctxType, FREContext ctx, uint32_t *numFunctionsToSet, const FRENamedFunction **functionsToSet);
void openaneWeChatContextFinalizer(FREContext ctx);
WeChatConnector *openaneWeChatContextNativeData(FREContext ctx);

ANE_FUNCTION(openaneWeChatFuncInit);
ANE_FUNCTION(openaneWeChatFuncIsInstalled);
ANE_FUNCTION(openaneWeChatFuncAuthorize);
ANE_FUNCTION(openaneWeChatFuncPay);
ANE_FUNCTION(openaneWeChatFuncHandleOpenURL);