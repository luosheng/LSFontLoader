//
//  LSFontLoader.h
//  LSFontLoader
//
//  Created by Luo Sheng on 13-1-23.
//  Copyright (c) 2013年 Luo Sheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreText/CoreText.h>
#import "LSPropertyListRequestOperation.h"
#import "LSFontAsset.h"

@interface LSFontLoader : NSObject

+ (instancetype)sharedLoader;
- (void)fetchManifest;
- (void)downloadFont:(LSFontAsset *)fontAsset;
- (void)loadFont:(LSFontAsset *)fontAsset;
- (void)loadFontForFamilyName:(NSString *)familyName;

@property (nonatomic, strong) NSArray *fontInfoList;
@property (nonatomic, copy) NSString *fontPath;

@end
