
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HKPDFRelativeDayFormatType) {
    HKPDFRelativeDayFormatTypeShort,
    HKPDFRelativeDayFormatTypeLong,
};

/**
 This class wraps an NSDateFormatter into a reusable container.
 */
@interface HKPDateFormatter : NSObject

/**
 @brief The singleton instance
 
 @returns Singleton instance of CTXDateFormatter
 @note it returns a singleton per thread, i.e., each thread has its private singleton which is not shared amongst threads
 */
+ (HKPDateFormatter *)sharedInstance;

/**
 @brief Builds a string from given date with format and locale.
 
 @param date The input date.
 @param dateFormat The input date formatting string.
 @param localeIdentifier The locale to use when parsing date
 @returns A string representation of passed date
 */
- (NSString *)stringFromDate:(NSDate *)date
              withDateFormat:(NSString *)dateFormat
            localeIdentifier:(NSString *)localeIdentifier;

/**
 @brief Build a relative date string from given date with format and locale.
 
 @param date The input date.
 @param dateFormat The input date formatting string.
 @param dayFormatType One of:
 
 - CTXDFRelativeDayShortType
 - CTXDFRelativeDayLongType
 
 @param localeIdentifier The locale to use when parsing date
 @param uppercaseRelativeDay Returns uppercase string
 @returns A string representation of passed date
 */
- (NSString *)relativeStringFromDate:(NSDate *)date
                      withDateFormat:(NSString *)dateFormat
                       dayFormatType:(HKPDFRelativeDayFormatType)dayFormatType
                    localeIdentifier:(NSString *)localeIdentifier
                uppercaseRelativeDay:(BOOL)uppercaseRelativeDay;

/**
 @brief Builds a date from given string with format and locale.
 
 @param string The input date in string format.
 @param dateFormat The input date formatting string.
 @param localeIdentifier The locale to use when parsing date
 @returns A date built from passed string or nil.
 */
- (NSDate *)dateFromString:(NSString *)string
            withDateFormat:(NSString *)dateFormat
          localeIdentifier:(NSString *)localeIdentifier;

/**
 @brief Builds a date from a given string using strptime (faster than NSDateFormatter).
 
 @param string The input date in string format
 @param format The input date formatting string. See strftime(3) for syntax.
 @returns A date built from passed string or nil.
 */
- (NSDate *)fastDateFromString:(NSString *)string withStrftimeFormat:(NSString *)format;

@end

