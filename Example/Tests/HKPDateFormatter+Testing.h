
#import "HKPDateFormatter.h"

@interface HKPDateFormatter (HKPInspectableDateFormatter)

@property (nonatomic, strong, readonly) NSMutableDictionary *localeDictionary;

+ (NSDictionary *)sharedInstances;
+ (instancetype)sharedInstance;

@end
