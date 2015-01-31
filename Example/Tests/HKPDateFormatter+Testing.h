
#import "HKPDateFormatter.h"

@interface HKPDateFormatter (HKPInspectableDateFormatter)

@property (nonatomic, strong, readonly) NSMutableDictionary *localeDictionary;

+ (NSDictionary *)sharedInstances;

@end
