//
// $id: openaneTencent.h openane $
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import "FlashRuntimeExtensions.h"

typedef enum {
    TencentOAuthStatusSuccess = 0,
    TencentOAuthStatusCancel = -1,
    TencentOAuthStatusFail = -2,
} TencentOAuthStatus;

@interface TencentConnector : NSObject<TencentSessionDelegate>

@property(readwrite, strong, nonatomic) TencentOAuth *oauth;
@property(readonly, assign, nonatomic) FREContext context;

- (id)initWithContext:(FREContext) ctx;

// Tencent
- (void)tencentDidLogin;
- (void)tencentDidNotLogin:(BOOL)cancelled;
- (void)tencentDidNotNetWork;

- (void)getUserInfoResponse:(APIResponse *)response;

- (void)didAuthorize:(TencentOAuthStatus)status withAPIResponse:(APIResponse *)response;

@end

void openaneTencentInitializer(void **extDataToSet, FREContextInitializer *ctxInitializerToSet, FREContextFinalizer *ctxFinalizerToSet);
void openaneTencentFinalizer(void *extData);