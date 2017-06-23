//
//  CMAttachement.m
//  xcsummary
//
//  Created by Titouan van Belle on 23.06.17.
//  Copyright © 2017 MacPaw inc. All rights reserved.
//

#import "CMAttachement.h"

@implementation CMAttachement

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _filename = dictionary[@"Filename"];
        _uniformTypeIdentifier = [self uniformTypeIdentifierFromString:dictionary[@"UniformTypeIdentifier"]];
    }
    return self;
}

- (CMUniformTypeIdentifier)uniformTypeIdentifierFromString:(NSString *)string
{
    if ([string isEqualToString:@"public.plain-text"]) {
        return CMUniformTypeIdentifierPlainText;
    }

    return 0;
}

@end
