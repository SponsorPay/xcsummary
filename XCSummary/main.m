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
        if (arguments.count < 3) {
            NSLog(@"Not enough arguments %@", arguments);
            return EXIT_FAILURE;
        }
        
        NSString *summary = CMSummaryGetValue(arguments, @"-s");
        NSString *activityLogs = CMSummaryGetValue(arguments, @"-a");
        NSString *output = CMSummaryGetValue(arguments, @"-o");
        if (!summary || !output) {
            NSLog(@"-s or -o was not provided %@", arguments);
            return EXIT_FAILURE;
        }

        CMTestActivityLogsReader *activityLogsReader = [[CMTestActivityLogsReader alloc] initWithPath:[activityLogs stringByExpandingTildeInPath]];
        NSString *logs = [activityLogsReader testLogs];

        NSString *summaryPath = [summary stringByExpandingTildeInPath];
        NSString *attachmentsPath = [[summaryPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Attachments"];
        
        CMTestSummaryParser *parser = [[CMTestSummaryParser alloc] initWithPath:summaryPath];
        NSArray *summaries = [parser testSummaries];
        
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

NSString *CMSummaryGetValue(NSArray *arguments, NSString *argument) {
    NSInteger index = [arguments indexOfObject:argument];
    if (index != NSNotFound) {
        return arguments[index+1];
    }
    return nil;
}

BOOL CMSummaryValueExists(NSArray *arguments, NSString *argument) {
    NSInteger index = [arguments indexOfObject:argument];
    return index != NSNotFound;
}
