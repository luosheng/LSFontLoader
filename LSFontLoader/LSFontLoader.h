//
//  LSFontLoader.h
//  LSFontLoader
//
//  Created by Luo Sheng on 13-1-23.
//  Copyright (c) 2013年 Luo Sheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSPropertyListRequestOperation.h"

@interface LSFontLoader : NSObject

+ (instancetype)sharedLoader;

- (void)fetchManifest;

@property (nonatomic, strong) NSArray *fontInfoList;

@end
