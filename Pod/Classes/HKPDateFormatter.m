

#import "HKPDateFormatter.h"

#import <time.h>
#import <xlocale.h>

static NSMutableDictionary const *_sharedInstances;

@interface HKPDateFormatter ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *dateRelativeFormatter;
@property (nonatomic, strong) NSMutableDictionary *localeDictionary;
@end

@implementation HKPDateFormatter

#pragma mark - Object creation/destruction

- (id)init
{
    if(self = [super init]) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateRelativeFormatter = [[NSDateFormatter alloc] init];
        [self.dateRelativeFormatter setDoesRelativeDateFormatting:YES];
        [self.dateRelativeFormatter setDateStyle:NSDateFormatterShortStyle];
        self.localeDictionary = [NSMutableDictionary dictionary];
        
        [self precacheLocales];
    }
    
    return self;
}

- (void)precacheLocales
{
    NSMutableDictionary *precachedLocaleDictionary;
    
    NSArray *localesIdentifier = @[@"en_US", @"it_IT"];
    precachedLocaleDictionary = [[NSMutableDictionary alloc] initWithCapacity:localesIdentifier.count];
    [localesIdentifier enumerateObjectsUsingBlock:^(NSString *localeIdentifier, NSUInteger index, BOOL *stop) {
        precachedLocaleDictionary[localeIdentifier] = [NSLocale localeWithLocaleIdentifier:localeIdentifier];
    }];
    
    [self.localeDictionary addEntriesFromDictionary:precachedLocaleDictionary];
}

+ (instancetype)sharedInstance
{
    static NSString * const singletonInstanceKey = @"dateFormatter";
    NSThread *currentThread = [NSThread currentThread];
    NSMutableDictionary *dictionary = [currentThread threadDictionary];
    
    if (!dictionary[singletonInstanceKey]) {
        dictionary[singletonInstanceKey] = [[HKPDateFormatter alloc] init];
    }
    
    return dictionary[singletonInstanceKey];
}

#pragma mark - Public methods

- (NSString *)stringFromDate:(NSDate *)date withDateFormat:(NSString *)dateFormat localeIdentifier:(NSString *)localeIdentifier
{
    [self.dateFormatter setDateFormat:dateFormat];
    NSLocale *locale = [self cacheLocaleIfNeeded:localeIdentifier];
    [self setupLocaleIfNeeded:locale dateRelativeFormatter:NO];
    return [self.dateFormatter stringFromDate:date];
}

- (NSDate *)dateFromString:(NSString *)string withDateFormat:(NSString *)dateFormat localeIdentifier:(NSString *)localeIdentifier
{
    [self.dateFormatter setDateFormat:dateFormat];
    NSLocale *locale = [self cacheLocaleIfNeeded:localeIdentifier];
    [self setupLocaleIfNeeded:locale dateRelativeFormatter:NO];
    return [self.dateFormatter dateFromString:string];
}

- (NSString *)relativeStringFromDate:(NSDate *)date
                      withDateFormat:(NSString *)dateFormat
                       dayFormatType:(HKPDFRelativeDayFormatType)dayFormatType
                    localeIdentifier:(NSString *)localeIdentifier
                uppercaseRelativeDay:(BOOL)uppercaseRelativeDay
{
    NSLocale *locale = [self cacheLocaleIfNeeded:localeIdentifier];
    [self setupLocaleIfNeeded:locale dateRelativeFormatter:YES];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    NSString *relativeDateFormat = (dayFormatType == HKPDFRelativeDayFormatTypeLong) ? @"EEEE" : @"EE";
    NSString *relativeString = [self relativeStringFromDate:date dateFormat:relativeDateFormat
                                       uppercaseRelativeDay:uppercaseRelativeDay];
    
    return [NSString stringWithFormat:@"%@ %@", relativeString, [self stringFromDate:date withDateFormat:dateFormat localeIdentifier:localeIdentifier]];
}

- (NSString *)relativeStringFromDate:(NSDate *)date dateFormat:(NSString *)dateFormat
                uppercaseRelativeDay:(BOOL)relativeDay
{
    NSString *relativeString = [self.dateRelativeFormatter stringFromDate:date];
    NSString *compareString = [self.dateFormatter stringFromDate:date];
    
    if ([relativeString isEqualToString:compareString]) {
        [self.dateFormatter setDateFormat:dateFormat];
        relativeString = [self.dateFormatter stringFromDate:date];
    } else if (relativeDay) {
        relativeString = [relativeString uppercaseString];
    }
    
    return relativeString;
}

- (NSLocale *)cacheLocaleIfNeeded:(NSString *)localeIdentifier
{
    
    static NSHashTable *availableLocaleIdentifier;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        availableLocaleIdentifier = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsStrongMemory capacity:8];
        for (NSString *localeIdentifier in [NSLocale availableLocaleIdentifiers]) {
            [availableLocaleIdentifier addObject:localeIdentifier];
        }
    });
    
    if (![availableLocaleIdentifier containsObject:localeIdentifier]) {
        return [self.localeDictionary.allValues firstObject];
    }
    
    NSLocale *locale = self.localeDictionary[localeIdentifier];
    if (!locale) {
        locale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier];
        self.localeDictionary[localeIdentifier] = locale;
    }
    
    return locale;
}

- (void)setupLocaleIfNeeded:(NSLocale *)locale dateRelativeFormatter:(BOOL)enableRelativeFormatter
{
    if(self.dateFormatter.locale != locale) {
        [self.dateFormatter setLocale:locale];
    }
}

- (NSDate *)fastDateFromString:(NSString *)string withStrftimeFormat:(NSString *)format
{
    if (!string.length) {
        return nil;
    }
    
    struct tm tm;
    time_t t;
    
    strptime_l([string cStringUsingEncoding:NSUTF8StringEncoding],
               [format cStringUsingEncoding:NSUTF8StringEncoding],
               &tm, NULL);
    tm.tm_isdst = -1;
    t = mktime(&tm);
    
    return [NSDate dateWithTimeIntervalSince1970:t];
}

@end

