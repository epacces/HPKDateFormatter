
#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>

#import "HKPDateFormatter.h"
#import "HKPDateFormatter+Testing.h"

static NSString * const kUnknownLocaleIdentifier = @"unknownLocaleIdentifier";
static NSString * const kUnknownDateFormat = @"unknownDateFormat";
static NSString * const kUnknownStringFormat = @"unknownStringFormat";

static NSString * const kUndefinedLocaleIdentifier = @"";
static NSString * const kUndefinedDateFormat = @"";
static NSString * const kUndefinedStringFormat = @"";

SPEC_BEGIN(HKPDateFormatterTest)

describe(@"Date formatter", ^{
    
    HKPDateFormatter __block *mainDateFormatter;
    HKPDateFormatter __block *firstBackgroundDateFormatter;
    HKPDateFormatter __block *secondBackgroundDateFormatter;
    
    dispatch_queue_t __block firstBackgroundQueue, secondBackgroundQueue;
    
    beforeAll(^{
        mainDateFormatter = [HKPDateFormatter sharedInstance];
        firstBackgroundQueue = dispatch_queue_create("firstBackgroundQueue", NULL);
        secondBackgroundQueue = dispatch_queue_create("secondBackgroundQueue", NULL);
       
        
        dispatch_async(secondBackgroundQueue, ^{
            secondBackgroundDateFormatter = [HKPDateFormatter sharedInstance];
        });
    });
    
    context(@"when initialized", ^{
        it(@"should not be nil", ^{
            [[mainDateFormatter shouldNot] beNil];
        });
        
        context(@"precached locale dictionary", ^{
            it(@"should not be nil", ^{
                [[mainDateFormatter.localeDictionary shouldNot] beNil];
            });
            
            it(@"should contain 2 locales", ^{
                [[mainDateFormatter.localeDictionary should] haveCountOf:2];
            });
            
            it(@"should contain it_IT, en_US locales", ^{
                NSLocale *italianLocale = [NSLocale localeWithLocaleIdentifier:@"it_IT"];
                NSLocale *englishLocale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
                [[mainDateFormatter.localeDictionary should] haveValue:italianLocale forKey:@"it_IT"];
                [[mainDateFormatter.localeDictionary should] haveValue:englishLocale forKey:@"en_US"];
            });
        });
        
    });
    
    context(@"when requested from the same thread", ^{
        HKPDateFormatter *secondaryDateFormatter = [HKPDateFormatter sharedInstance];
        it(@"should point to the same address", ^{
            BOOL sameAddress = (mainDateFormatter == secondaryDateFormatter);
            [[theValue(sameAddress) should] beTrue];
        });
    });
    
    context(@"when requested from different threads", ^{
        HKPDateFormatter __block *secondaryDateFormatter;
        beforeEach(^{
            dispatch_async(firstBackgroundQueue, ^{
                secondaryDateFormatter = [HKPDateFormatter sharedInstance];
            });
        });
        
        it(@"should point to different address", ^{
            [[expectFutureValue(secondBackgroundDateFormatter) shouldNotEventually] beIdenticalTo:mainDateFormatter];
        });
        
        context(@"when requested 2 instances from the same thread", ^{
            
            HKPDateFormatter __block *dateFormatter;
            beforeAll(^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    dateFormatter = [HKPDateFormatter sharedInstance];
                });
            });
            
            it(@"should point to the same address", ^{
                [[expectFutureValue(dateFormatter) shouldEventually] beIdenticalTo:mainDateFormatter];
            });
            
            it(@"should point to two different addresses", ^{
                [[expectFutureValue(secondaryDateFormatter) shouldNotEventually] beIdenticalTo:mainDateFormatter];
            });
        });
    });
    
    context(@"precached locale dictionary", ^{
        
        NSDate __block *now;
        
        beforeAll(^{
            now = [NSDate date];
        });
        
        context(@"single thread", ^{
            it(@"should contain 2 precached locales", ^{
                [[HKPDateFormatter sharedInstance] stringFromDate:now withDateFormat:@"HH:mm:ss"
                                                 localeIdentifier:@"en_US"];
                [[mainDateFormatter.localeDictionary should] haveCountOf:2];
            });
            
            it(@"should contain 3 precached locales", ^{
                [[HKPDateFormatter sharedInstance] stringFromDate:now withDateFormat: @"HH:mm:ss"
                                                 localeIdentifier:@"en_GB"];
                [[mainDateFormatter.localeDictionary should] haveCountOf:3];
            });
        });
        
        
    });
    
    
    context(@"conversion", ^{
        
        NSDateFormatter __block *dateFormatter;
        beforeAll(^{
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
        });
        
        context(@"turn a date into a string", ^{
            
            NSDate __block *now;
            NSString __block *testDateFormat;
            beforeAll(^{
                now = [NSDate date];
                testDateFormat = @"YY/MM/dd - HH:mm:ss";
            });
            
            context(@"single thread", ^{
                
                it(@"should be equal to result of NSDateFormatter", ^{
                    NSString *string = [[HKPDateFormatter sharedInstance]
                                        stringFromDate:[NSDate date]
                                        withDateFormat:testDateFormat
                                        localeIdentifier:@"en_US"];
                    
                    dateFormatter.dateFormat =  @"YY/MM/dd - HH:mm:ss";
                    BOOL areEqual = [string isEqualToString:[dateFormatter stringFromDate:now]];
                    
                    [[theValue(areEqual) should] beTrue];
                });
                
                context(@"wrong format", ^{
                    it(@"should return an empty string ", ^{
                        NSString *string = [[HKPDateFormatter sharedInstance]
                                            stringFromDate:[NSDate date] withDateFormat:kUndefinedDateFormat
                                            localeIdentifier:@"en_US"];
                        [[string should] haveLengthOf:0];
                    });
                    
                    it(@"should return an empty string", ^{
                        NSString *string = [[HKPDateFormatter sharedInstance]
                                            stringFromDate:[NSDate date] withDateFormat:kUnknownDateFormat
                                            localeIdentifier:@"en_US"];
                        [[string should] haveLengthOfAtLeast:0];
                    });
                });
                
                context(@"wrong locale", ^{
                    it(@"should return a non empty string", ^{
                        NSString *string = [[HKPDateFormatter sharedInstance]
                                            stringFromDate:[NSDate date] withDateFormat:testDateFormat
                                            localeIdentifier:kUnknownDateFormat];
                        [[string should] haveLengthOfAtLeast:1];
                    });
                    
                    it(@"should return a string with default locale", ^{
                        NSString *string = [[HKPDateFormatter sharedInstance]
                                            stringFromDate:[NSDate date] withDateFormat:testDateFormat
                                            localeIdentifier:kUnknownDateFormat];
                        dateFormatter.dateFormat = testDateFormat;
                        BOOL areEqual = [string isEqualToString:[dateFormatter stringFromDate:now]];
                        
                        [[theValue(areEqual) should] beTrue];
                    });
                    
                    it(@"should return a non empty string", ^{
                        NSString *string = [[HKPDateFormatter sharedInstance]
                                            stringFromDate:[NSDate date] withDateFormat:testDateFormat
                                            localeIdentifier:kUndefinedLocaleIdentifier];
                        [[string should] haveLengthOfAtLeast:1];
                    });
                });
            });
            
            context(@"multi thread", ^{
                it(@"should be equal to results of NSDateFormatter", ^{
                    
                    NSString __block *firstResult, *secondResult, *thirdResult;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        firstResult = [[HKPDateFormatter sharedInstance]
                                       stringFromDate:now withDateFormat:testDateFormat localeIdentifier:@"en_US"];
                    });
                    
                    dispatch_async(firstBackgroundQueue, ^{
                        secondResult = [[HKPDateFormatter sharedInstance]
                                        stringFromDate:now withDateFormat:testDateFormat localeIdentifier:@"en_US"];
                    });
                    
                    dispatch_async(secondBackgroundQueue, ^{
                        thirdResult = [[HKPDateFormatter sharedInstance]
                                       stringFromDate:now withDateFormat:testDateFormat localeIdentifier:@"en_US"];
                    });
                    
                    dateFormatter.dateFormat = testDateFormat;
                    
                    NSString *expectedString = [dateFormatter stringFromDate:now];
                    [[expectFutureValue(@([firstResult isEqualToString:expectedString])) shouldEventually] beTrue];
                    [[expectFutureValue(@([secondResult isEqualToString:expectedString])) shouldEventually] beTrue];
                    [[expectFutureValue(@([thirdResult isEqualToString:expectedString])) shouldEventually] beTrue];
                });
            });

        });
        
        context(@"turn a string into a date", ^{
            
            NSString __block *perfectDay;
            NSString __block *testDateFormat;

            beforeAll(^{
                perfectDay = @"11/12/13";
                testDateFormat = @"dd/mm/yy";
            });
            
            context(@"single thread", ^{
                it(@"should be equal to result of NSDateFormatter", ^{
                    dateFormatter.dateFormat = @"dd/mm/yy";
                    [dateFormatter dateFromString:perfectDay];
                    NSDate *date = [[HKPDateFormatter sharedInstance]
                                    dateFromString:perfectDay
                                    withDateFormat:testDateFormat
                                    localeIdentifier:@"en_US"];
                    
                    BOOL haveTheSameDate = [date isEqualToDate:[dateFormatter dateFromString:perfectDay]];
                    
                    [[theValue(haveTheSameDate) should] beTrue];
                });
                
                context(@"wrong format", ^{
                    it(@"should return a nil date", ^{
                        NSDate *date = [[HKPDateFormatter sharedInstance]
                                        dateFromString:perfectDay
                                        withDateFormat: @"undefined format"
                                        localeIdentifier:@"en_US"];
                        [[date should] beNil];
                    });
                    
                    it(@"should return a nil date", ^{
                        NSDate *date = [[HKPDateFormatter sharedInstance]
                                        dateFromString:perfectDay
                                        withDateFormat: @""
                                        localeIdentifier:@"en_US"];
                        [[date should] beNil];
                    });
                });
                
                context(@"wrong locale", ^{
                    it(@"should return a nil date", ^{
                        NSDate *date = [[HKPDateFormatter sharedInstance]
                                        dateFromString:perfectDay
                                        withDateFormat:testDateFormat
                                        localeIdentifier:kUnknownLocaleIdentifier];
                        [[date should] beNonNil];
                    });
                    
                    it(@"should return a nil date", ^{
                        NSDate *date = [[HKPDateFormatter sharedInstance]
                                        dateFromString:perfectDay
                                        withDateFormat:testDateFormat
                                        localeIdentifier:kUndefinedLocaleIdentifier];
                        [[date should] beNonNil];
                    });
                    
                    it(@"should return a date with default locale", ^{
                        NSDate *date = [[HKPDateFormatter sharedInstance]
                                        dateFromString:perfectDay
                                        withDateFormat:testDateFormat
                                        localeIdentifier:@"en_US"];
                        
                        dateFormatter.dateFormat = testDateFormat;
                        BOOL haveTheSameDate = [date isEqualToDate:[dateFormatter dateFromString:perfectDay]];
                        
                        [[theValue(haveTheSameDate) should] beTrue];
                    });
                });
                
                context(@"multiple thread", ^{
                    it(@"should be equal to results of NSDateFormatter", ^{
                        NSDate __block *firstResult, *secondResult, *thirdResult;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            firstResult = [[HKPDateFormatter sharedInstance]
                                           dateFromString:perfectDay
                                           withDateFormat:testDateFormat localeIdentifier:@"en_US"];
                        });
                        
                        dispatch_async(firstBackgroundQueue, ^{
                            secondResult = [[HKPDateFormatter sharedInstance]
                                            dateFromString:perfectDay
                                            withDateFormat:testDateFormat
                                            localeIdentifier:@"en_US"];
                        });
                        
                        dispatch_async(secondBackgroundQueue, ^{
                            thirdResult = [[HKPDateFormatter sharedInstance]
                                           dateFromString:perfectDay
                                           withDateFormat:testDateFormat
                                           localeIdentifier:@"en_US"];
                        });
                        
                        dateFormatter.dateFormat = testDateFormat;
                        
                        NSDate *expectedDate = [dateFormatter dateFromString:perfectDay];
                        [[expectFutureValue(@([firstResult isEqualToDate:expectedDate])) shouldEventually] beTrue];
                        [[expectFutureValue(@([secondResult isEqualToDate:expectedDate])) shouldEventually] beTrue];
                        [[expectFutureValue(@([thirdResult isEqualToDate:expectedDate])) shouldEventually] beTrue];
                    });
                });
                
            });
        });
        
                
    });
});

SPEC_END
