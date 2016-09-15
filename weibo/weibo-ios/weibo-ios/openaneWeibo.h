//
// $id: openaneWeibo.h openane $
//

#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"
#import "WeiboSDK.h"
#import "FlashRuntimeExtensions.h"

@interface WeiboConnector : NSObject<WeiboSDKDelegate>
@property(readonly, assign, nonatomic) FREContext context;
@property(readwrite, strong, nonatomic) NSString *redirectURI;
@property(readwrite, strong, nonatomic) NSString *scope;

- (id)initWithContext:(FREContext) ctx;

/* WeiboSDKDelegate */
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request;
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response;

@end

void openaneWeiboInitializer(void **extDataToSet, FREContextInitializer *ctxInitializerToSet, FREContextFinalizer *ctxFinalizerToSet);
void openaneWeiboFinalizer(void *extData);