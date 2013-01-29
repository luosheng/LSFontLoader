//
//  LSFontLoader.m
//  LSFontLoader
//
//  Created by Luo Sheng on 13-1-23.
//  Copyright (c) 2013年 Luo Sheng. All rights reserved.
//

#import "LSFontLoader.h"
#import "SSZipArchive.h"

@interface LSFontLoader ()

- (NSString *)pathForFontAsset:(LSFontAsset *)asset;
- (void)loadFontForPath:(NSString *)fontPath;

@property (nonatomic, strong) NSArray *fontAssets;

@end

@implementation LSFontLoader

+ (instancetype)sharedLoader {
	static dispatch_once_t onceToken;
	static LSFontLoader *instance = nil;
	dispatch_once(&onceToken, ^{
    instance = [[LSFontLoader alloc] init];
	});
	return instance;
}

- (id)init {
	self = [super init];
	if (self) {
		_fontPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"LSFonts"];
		_fontAssets = @[];
	}
	return self;
}

- (void)fetchManifestWithCompleteBlock:(void (^)(void))completeBlock {
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mesu.apple.com/assets/com_apple_MobileAsset_Font/com_apple_MobileAsset_Font.xml"]];
	LSPropertyListRequestOperation *operation = [LSPropertyListRequestOperation propertyListRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id propertyList) {
		NSArray *assets = propertyList[@"Assets"];
		NSMutableArray *array = [NSMutableArray array];
		[assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			LSFontAsset *info = [[LSFontAsset alloc] initWithDictionary:obj];
			[array addObject:info];
		}];
		self.fontAssets = [array copy];
		
		if (completeBlock) {
			completeBlock();
		}
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id propertyList) {
		
	}];
	[operation start];
}

- (void)downloadFont:(LSFontAsset *)fontAsset withCompleteBlock:(void (^)(void))completeBlock downloadProgressBlock:(void (^)(NSUInteger, long long, long long))downloadProgressBlock {
	NSURL *downloadURL = fontAsset.downloadURL;
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:downloadURL]];
	NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:downloadURL.lastPathComponent];
	operation.outputStream = [NSOutputStream outputStreamToFileAtPath:tempPath append:NO];
	[operation setDownloadProgressBlock:downloadProgressBlock];
	operation.completionBlock = ^{
		NSString *destinationPath = [self.fontPath stringByAppendingPathComponent:[self pathForFontAsset:fontAsset]];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[SSZipArchive unzipFileAtPath:tempPath toDestination:destinationPath];
			dispatch_async(dispatch_get_main_queue(), completeBlock);
		});
	};
	[operation start];
}

- (void)loadFontForPath:(NSString *)fontPath {
	NSArray *fontNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fontPath error:nil];
	if (fontNames) {
		NSString *fontName = fontNames.lastObject;
		NSURL *fontURL = [NSURL fileURLWithPath:[fontPath stringByAppendingPathComponent:fontName]];
		CFErrorRef error;
		if (!CTFontManagerRegisterFontsForURL((__bridge CFURLRef)(fontURL), kCTFontManagerScopeProcess, &error)) {
			CFStringRef errorDescription = CFErrorCopyDescription(error);
			NSLog(@"Failed to load font: %@", errorDescription);
			CFRelease(errorDescription);
		}
	}
}

- (void)loadFont:(LSFontAsset *)fontAsset {
	NSString *fontPath = [[self.fontPath stringByAppendingPathComponent:[self pathForFontAsset:fontAsset]] stringByAppendingPathComponent:@"AssetData"];
	[self loadFontForPath:fontPath];
}

- (BOOL)isFontDownloaded:(LSFontAsset *)fontAsset {
	return [[NSFileManager defaultManager] fileExistsAtPath:[self.fontPath stringByAppendingPathComponent:[self pathForFontAsset:fontAsset]]];
}

#pragma mark - Private methods

- (NSString *)pathForFontAsset:(LSFontAsset *)asset {
	NSMutableArray *array = [NSMutableArray array];
	[asset.infoList enumerateObjectsUsingBlock:^(LSFontInfo *info, NSUInteger idx, BOOL *stop) {
		[array addObject:info.name];
	}];
	NSString *path = [NSString stringWithFormat:@"[%@]%@", asset.familyName, [array componentsJoinedByString:@"_"]];
	return path;
}

@end
