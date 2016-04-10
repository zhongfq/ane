//
// $id: openane.h openane $
//

#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"

#define ANE_FUNCTION(f) FREObject (f)(FREContext ctx, void *data, uint32_t argc, FREObject argv[])
#define MAP_FUNCTION(fn, f, data) {(const uint8_t *)(fn), (data), &(f)}
#define FRESTR(s) ((const uint8_t *)(s))

#define FREPrint(s) FREDispatchStatusEventAsync(ctx, FRESTR("print"), FRESTR(s))
#define UNUSED(e) (void)(e)

NSString *openaneObjectToString(FREObject obj);
NSNumber *openaneObjectToNumber(FREObject obj);
NSString *openaneObjectToJSONString(NSObject *obj);

@interface Connector : NSObject

@property(readonly, assign, nonatomic) FREContext context;

- (id)initWithContext:(FREContext) ctx;

@end