//
//  CMHTMLReportBuilder.m
//  xcsummary
//
//  Created by Kryvoblotskyi Sergii on 12/13/16.
//  Copyright © 2016 MacPaw inc. All rights reserved.
//

#import "CMHTMLReportBuilder.h"
#import "CMTest.h"
#import "CMTestableSummary.h"
#import "CMActivitySummary.h"
#import "TemplateGeneratedHeader.h"

@interface CMHTMLReportBuilder ()

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *resultsPath;
@property (nonatomic, copy) NSString *htmlResourcePath;

@property (nonatomic, strong) NSMutableString *resultString;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic) BOOL showSuccessTests;

@property (nonatomic, strong) NSDateComponentsFormatter *timeFormatter;

@end

@implementation CMHTMLReportBuilder

- (instancetype)initWithAttachmentsPath:(NSString *)path
                            resultsPath:(NSString *)resultsPath
                       showSuccessTests:(BOOL)showSuccessTests
                           activityLogs:(NSString *)activityLogs
{
    self = [super init];

    if (self)
    {
        _fileManager = [NSFileManager defaultManager];
        _path = path;
        _resultsPath = resultsPath;
        _htmlResourcePath = [[resultsPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"resources"];
        _resultString = [NSMutableString new];
        _showSuccessTests = showSuccessTests;
        [self _prepareResourceFolder];

        NSString *logFile = [_htmlResourcePath stringByAppendingPathComponent:@"activityLogs.txt"];
        [activityLogs writeToFile:logFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }

    return self;
}

- (NSDateComponentsFormatter *)timeFormatter
{
    if (!_timeFormatter)
    {
        NSDateComponentsFormatter *formatter = [NSDateComponentsFormatter new];
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleAbbreviated;
        formatter.allowedUnits = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        _timeFormatter = formatter;
    }
    return _timeFormatter;
}

#pragma mark - Public

- (void)appendSummaries:(NSArray <CMTestableSummary *> *)summaries
{
    NSUInteger successfullTests = [[summaries valueForKeyPath:@"@sum.numberOfSuccessfulTests"] integerValue];
    NSUInteger failedTests = [[summaries valueForKeyPath:@"@sum.numberOfFailedTests"] integerValue];
 
    BOOL failuresPresent = failedTests > 0;
    NSString *templateFormat = [self _decodeTemplateWithName:SummaryTemplate];
    NSString *header = [NSString stringWithFormat:templateFormat, successfullTests + failedTests, successfullTests, failuresPresent ? @"inline": @"none", failedTests];
    [self.resultString appendString:header];
}

- (void)appendTests:(NSArray *)tests
{
    [tests enumerateObjectsUsingBlock:^(CMTest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [self _appendTestCase:obj];

        if (obj.subTests.count > 0) {
            [self appendTests:obj.subTests];
        } else {
            if (self.showSuccessTests == NO) {
                if (obj.status == CMTestStatusFailure) {
                    [self _appendActivitiesForTest:obj];
                }
            } else {
                [self _appendActivitiesForTest:obj];
            }
        }
    }];
}

- (NSString *)build
{
    NSString *templateFormat = [self _decodeTemplateWithName:Template];
    return [NSString stringWithFormat:templateFormat, self.resultString.copy];
}

#pragma mark - Private

- (NSString *)_decodeTemplateWithName:(NSString *)fileName
{
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:fileName options:0];
    NSString *format = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    return format;
}

- (void)_appendTestCase:(CMTest *)testCase
{
    NSString *templateFormat;
    NSString *composedString;

    if ([testCase.testName isEqualToString:@"app"]) {
        return;
    }

    if (testCase.status == CMTestStatusFailure) {
        templateFormat = [self _decodeTemplateWithName:TestCaseTemplateFailed];
        composedString = [NSString stringWithFormat:templateFormat, testCase.testSummaryGUID, testCase.testName, testCase.duration];
    } else {
        if (!testCase.activities) {
            templateFormat = [self _decodeTemplateWithName:TestCaseHeader];
            composedString = [NSString stringWithFormat:templateFormat, testCase.testName, testCase.duration];
        } else {
            templateFormat = [self _decodeTemplateWithName:TestCaseTemplate];
            composedString = [NSString stringWithFormat:templateFormat, testCase.testSummaryGUID, testCase.testName, testCase.duration];
        }
    }

    [self.resultString appendString:composedString];
}

- (void)_appendActivitiesForTest:(CMTest *)test
{
    NSString *startTag = [NSString stringWithFormat:@"<div id=\"%@\" style=\"display:none;\">", test.testSummaryGUID];
    [self.resultString appendString:startTag];
    [self _appendActivities:test.activities];
    [self.resultString appendString:@"</div>"];
}

- (void)_appendActivities:(NSArray <CMActivitySummary *> *)activities
{
    [activities enumerateObjectsUsingBlock:^(CMActivitySummary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self _appendActivity:obj];
        [self _appendActivities:obj.subActivities];
    }];
}

- (void)_appendActivity:(CMActivitySummary *)activity
{
    NSString *templateFormat;
    NSString *composedString;

    if (activity.hasScreenshotData) {
        templateFormat = [self _decodeTemplateWithName:ActivityTemplateWithImage];
        NSString *imageName = [NSString stringWithFormat:@"Screenshot_%@.png", activity.uuid.UUIDString];
        NSString *fullPath = [self.path stringByAppendingPathComponent:imageName];

        composedString = [NSString stringWithFormat:templateFormat, activity.title, activity.finishTimeInterval - activity.startTimeInterval, activity.uuid.UUIDString, activity.uuid.UUIDString, fullPath];
    } else {
        templateFormat = [self _decodeTemplateWithName:ActivityTemplateWithoutImage];
        composedString = [NSString stringWithFormat:templateFormat, activity.title, activity.finishTimeInterval - activity.startTimeInterval];
    }
    
    [self.resultString appendString:composedString];
}

#pragma mark - File Operations

- (void)_prepareResourceFolder
{
    if ([self.fileManager fileExistsAtPath:self.htmlResourcePath] == NO) {
        [self.fileManager createDirectoryAtPath:self.htmlResourcePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
}

@end
