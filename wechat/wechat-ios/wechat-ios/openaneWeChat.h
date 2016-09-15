//
// $id: openaneWeChat.h openane $
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FlashRuntimeExtensions.h"
#import "WXApi.h"

@interface WeChatConnector : NSObject<WXApiDelegate>
@property(readwrite, strong, nonatomic) NSString *appID;
@property(readwrite, strong, nonatomic) NSString *appSecret;
@property(readonly, assign, nonatomic) FREContext context;

- (id)initWithContext:(FREContext) ctx;

// wechat sdk
- (void)onReq:(BaseReq*)req;
- (void)onResp:(BaseResp*)resp;

@end

void openaneWeChatInitializer(void **extDataToSet, FREContextInitializer *ctxInitializerToSet, FREContextFinalizer *ctxFinalizerToSet);
void openaneWeChatFinalizer(void *extData);