//
// $id: openaneTencent.h openane $
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import "openane.h"

typedef enum {
    TencentOAuthStatusSuccess = 0,
    TencentOAuthStatusCancel = -1,
    TencentOAuthStatusFail = -2,
} TencentOAuthStatus;

@interface TencentConnector : Connector<TencentSessionDelegate>

@property(readwrite, strong, nonatomic) TencentOAuth *oauth;

// Tencent
- (void)tencentDidLogin;
- (void)tencentDidNotLogin:(BOOL)cancelled;
- (void)tencentDidNotNetWork;

- (void)getUserInfoResponse:(APIResponse *)response;

- (void)didAuthorize:(TencentOAuthStatus)status withAPIResponse:(APIResponse *)response;

@end

#define DLOG(fmt, ...) OPENANE_LOG(@"openaneTencent", fmt, ##__VA_ARGS__)

void openaneTencentInitializer(void **extDataToSet, FREContextInitializer *ctxInitializerToSet, FREContextFinalizer *ctxFinalizerToSet);
void openaneTencentFinalizer(void *extData);

void openaneTencentContextInitializer(void *extData, const uint8_t *ctxType, FREContext ctx, uint32_t *numFunctionsToSet, const FRENamedFunction **functionsToSet);
void openaneTencentContextFinalizer(FREContext ctx);
TencentConnector *openaneTencentContextNativeData(FREContext ctx);

ANE_FUNCTION(openaneTencentFuncInit);
ANE_FUNCTION(openaneTencentFuncAuthorize);
ANE_FUNCTION(openaneTencentFuncHandleOpenURL);