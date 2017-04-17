//
//  main.m
//  xcsummary
//
//  Created by Kryvoblotskyi Sergii on 12/13/16.
//  Copyright © 2016 MacPaw inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMTestSummaryParser.h"
#import "CMHTMLReportBuilder.h"
#import "CMTestActivityLogsReader.h"
#import "CMTestableSummary.h"
#import "CMTest.h"

NSString *CMSummaryGetValue(NSArray *arguments, NSString *argument);
BOOL CMSummaryValueExists(NSArray *arguments, NSString *argument);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        if (arguments.count < 1) {
            NSLog(@"Not enough arguments %@", arguments);
            return EXIT_FAILURE;
        }

//        ./build/xcsummary -r build_reports/results

        NSString *results = CMSummaryGetValue(arguments, @"-r");
        NSString *attachmentsPath = [NSString stringWithFormat:@"%@/2_Test/Attachments", results.lastPathComponent];
        NSString *summary = [NSString stringWithFormat:@"%@/2_Test/action_TestSummaries.plist", results];
        NSString *activityLogs = [NSString stringWithFormat:@"%@/2_Test/action.xcactivitylog", results];

        if (!results) {
            NSLog(@"Argument -r was not provided");
            return EXIT_FAILURE;
        }

        CMTestActivityLogsReader *activityLogsReader = [[CMTestActivityLogsReader alloc] initWithPath:[activityLogs stringByExpandingTildeInPath]];
        NSString *logs = [activityLogsReader testLogs];

        NSString *summaryPath = [summary stringByExpandingTildeInPath];
        CMTestSummaryParser *parser = [[CMTestSummaryParser alloc] initWithPath:summaryPath];
        NSArray <CMTestableSummary *> *summaries = [parser testSummaries];

        NSString *output = [NSString stringWithFormat:@"%@/%@.html", [results stringByDeletingLastPathComponent], summaries[0].targetName];

        BOOL showSuccess = YES;
        CMHTMLReportBuilder *builder = [[CMHTMLReportBuilder alloc] initWithAttachmentsPath:attachmentsPath
                                                                                resultsPath:output.stringByExpandingTildeInPath
                                                                           showSuccessTests:showSuccess
                                                                               activityLogs:logs];
        [builder appendSummaries:summaries];
        [summaries enumerateObjectsUsingBlock:^(CMTestableSummary *summary, NSUInteger idx, BOOL * _Nonnull stop) {
            [builder appendTests:summary.tests];
        }];
        
        NSString *htmlResult = [builder build];
        return [[htmlResult dataUsingEncoding:NSUTF8StringEncoding] writeToFile:output.stringByExpandingTildeInPath
                                                                     atomically:YES] == YES ? EXIT_SUCCESS : EXIT_FAILURE;
    }
    return 0;
}

NSString *CMSummaryGetValue(NSArray *arguments, NSString *argument)
{
    NSInteger index = [arguments indexOfObject:argument];

    if (index != NSNotFound) {
        return arguments[index + 1];
    }

    return nil;
}

BOOL CMSummaryValueExists(NSArray *arguments, NSString *argument)
{
    NSInteger index = [arguments indexOfObject:argument];
    return index != NSNotFound;
}
