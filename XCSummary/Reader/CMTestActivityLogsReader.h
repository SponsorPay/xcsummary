//
//  CMTestActivityLogsReader.h
//  XCSummary
//
//  Created by Titouan van Belle on 13/04/2017.
//  Copyright © 2017 MacPaw inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMTestActivityLogsReader : NSObject

@property (nonatomic, copy, readonly) NSString *path;

- (instancetype)initWithPath:(NSString *)path;

- (NSString *)testLogs;

@end
