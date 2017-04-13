//
//  CMTestActivityLogsReader.m
//  XCSummary
//
//  Created by Titouan van Belle on 13/04/2017.
//  Copyright © 2017 MacPaw inc. All rights reserved.
//

#import "CMTestActivityLogsReader.h"
#import "NSData+GZIP.h"

@implementation CMTestActivityLogsReader

- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];

    if (self) {
        _path = path;
    }

    return self;
}

- (NSString *)testLogs
{
    NSData *fileData = [NSData dataWithContentsOfFile:self.path];
    NSData *gunzippedFileData = [fileData gunzippedData];

    return [[NSString alloc] initWithData:gunzippedFileData encoding:NSUTF8StringEncoding];
}

@end
