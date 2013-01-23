//
//  LSFontInfo.h
//  LSFontLoader
//
//  Created by Luo Sheng on 13-1-23.
//  Copyright (c) 2013年 Luo Sheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSFontInfo : NSObject

- (id)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, strong) NSDictionary *info;
@property (nonatomic, readonly) NSURL *downloadURL;

@end
