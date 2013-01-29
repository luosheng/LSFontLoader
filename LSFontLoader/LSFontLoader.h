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
#import "LSFontInfo.h"
#import "AFNetworking.h"

@interface LSFontLoader : NSObject

+ (instancetype)sharedLoader;
- (void)fetchManifestWithCompleteBlock:(void (^)(void))completeBlock;
- (void)downloadFont:(LSFontAsset *)fontAsset withCompleteBlock:(void (^)(void))completeBlock downloadProgressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))downloadProgressBlock;
- (void)loadFont:(LSFontAsset *)fontAsset;
- (void)unloadFont:(LSFontAsset *)fontAsset;
- (BOOL)isFontDownloaded:(LSFontAsset *)fontAsset;

@property (nonatomic, readonly, strong) NSArray *fontAssets;
@property (nonatomic, copy) NSString *fontBasePath;

@end
