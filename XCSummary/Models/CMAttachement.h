//
//  CMAttachement.h
//  xcsummary
//
//  Created by Titouan van Belle on 23.06.17.
//  Copyright © 2017 MacPaw inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CMUniformTypeIdentifier) {
    CMUniformTypeIdentifierPlainText,
};

@interface CMAttachement : NSObject

@property (nonatomic, copy, readonly) NSString *filename;
@property (nonatomic, assign, readonly) CMUniformTypeIdentifier uniformTypeIdentifier;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
