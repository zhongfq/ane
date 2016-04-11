//
// $id: openane.m openane $
//

#import "openane.h"

NSString *openaneObjectToString(FREObject obj)
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

NSNumber *openaneObjectToNumber(FREObject obj)
{
    double value = 0;

    if (FREGetObjectAsDouble(obj, &value) == FRE_OK)
    {
        return [NSNumber numberWithDouble:value];
    }
    else
    {
        NSString *numstr = openaneObjectToString(obj);
        return [NSNumber numberWithDouble:numstr != NULL ? [numstr doubleValue] : 0];
    }
}

NSString *openaneObjectToJSONString(NSObject *obj)
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@implementation Connector

- (id)initWithContext:(FREContext)ctx
{
    if ((self = [super init]) != nil)
    {
        _context = ctx;
    }
    
    return self;
}

@end
