//
//  LSFontLoader.m
//  LSFontLoader
//
//  Created by Luo Sheng on 13-1-23.
//  Copyright (c) 2013年 Luo Sheng. All rights reserved.
//

#import "LSFontLoader.h"
#import "SSZipArchive.h"
#include <sys/xattr.h>
#import "AFDownloadRequestOperation.h"

#define FONT_ASSET_URL @"http://mesu.apple.com/assets/com_apple_MobileAsset_Font/com_apple_MobileAsset_Font.xml"

@interface LSFontLoader ()

- (NSString *)pathForFontAsset:(LSFontAsset *)asset;
- (void)parseFontAssetListForPath:(NSString *)fontAssetListPath;
- (void)loadFontForPath:(NSString *)fontPath;
- (void)unloadFontForPath:(NSString *)fontPath;

+ (NSString *)localFontAssetListPath;

@property (nonatomic, copy) NSArray *fontAssets;

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

+ (NSString *)fontBasePath {
	return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"LSFonts"];
}

+ (NSString *)localFontAssetListPath {
	return [self.fontBasePath stringByAppendingPathComponent:[FONT_ASSET_URL lastPathComponent]];
}

- (id)init {
	self = [super init];
	if (self) {
		_fontAssets = @[];
		
		NSURL *fontPathURL = [NSURL fileURLWithPath:self.class.fontBasePath];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		if ([fileManager createDirectoryAtURL:fontPathURL withIntermediateDirectories:YES attributes:nil error:nil]) {
			const char* filePath = [[fontPathURL path] fileSystemRepresentation];
			
			const char* attrName = "com.apple.MobileBackup";
			u_int8_t attrValue = 1;
			
			setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
		}
		
		if (![fileManager fileExistsAtPath:self.class.localFontAssetListPath]) {
			NSError *error = nil;
			NSString *srcPath = [[NSBundle mainBundle] pathForResource:[FONT_ASSET_URL lastPathComponent] ofType:nil];
			[fileManager copyItemAtPath:srcPath toPath:self.class.localFontAssetListPath error:&error];
		}
		
		[self parseFontAssetListForPath:self.class.localFontAssetListPath];
	}
	return self;
}

- (void)parseFontAssetListForPath:(NSString *)fontAssetListPath {
	NSPropertyListFormat format;
	NSError *error = nil;
	NSData *fontAssetListData = [NSData dataWithContentsOfFile:fontAssetListPath];
	id propertyList = [NSPropertyListSerialization propertyListWithData:fontAssetListData options:NSPropertyListImmutable format:&format error:&error];
	if (!error) {
		NSArray *assets = propertyList[@"Assets"];
		NSMutableArray *array = [NSMutableArray array];
		[assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			LSFontAsset *info = [[LSFontAsset alloc] initWithDictionary:obj];
			[array addObject:info];
		}];
		self.fontAssets = array;
	}
}

- (void)fetchManifestWithCompletionBlock:(void (^)(void))completionBlock {
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:FONT_ASSET_URL]];
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	operation.outputStream = [[NSOutputStream alloc] initToFileAtPath:self.class.localFontAssetListPath append:NO];
	operation.completionBlock = ^{
		[self parseFontAssetListForPath:self.class.localFontAssetListPath];
		if (completionBlock) {
			completionBlock();
		}
	};
	[operation start];
}

- (NSOperation *)downloadFont:(LSFontAsset *)fontAsset withCompletionBlock:(void (^)(void))completionBlock downloadProgressBlock:(void (^)(NSUInteger, long long, long long))downloadProgressBlock {
	NSURL *downloadURL = fontAsset.downloadURL;
	NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:downloadURL.lastPathComponent];
	AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:downloadURL] targetPath:tempPath shouldResume:YES];
	[operation setDownloadProgressBlock:downloadProgressBlock];
	operation.completionBlock = ^{
		NSString *destinationPath = [self.class.fontBasePath stringByAppendingPathComponent:[self pathForFontAsset:fontAsset]];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[SSZipArchive unzipFileAtPath:tempPath toDestination:destinationPath];
			dispatch_async(dispatch_get_main_queue(), completionBlock);
		});
	};
	[operation start];
	return operation;
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

- (void)unloadFontForPath:(NSString *)fontPath {
	NSArray *fontNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fontPath error:nil];
	if (fontNames) {
		NSString *fontName = fontNames.lastObject;
		NSURL *fontURL = [NSURL fileURLWithPath:[fontPath stringByAppendingPathComponent:fontName]];
		CFErrorRef error;
		CTFontManagerUnregisterFontsForURL((__bridge CFURLRef)(fontURL), kCTFontManagerScopeProcess, &error);
	}
}

- (void)loadFont:(LSFontAsset *)fontAsset {
	NSString *fontPath = [[self.class.fontBasePath stringByAppendingPathComponent:[self pathForFontAsset:fontAsset]] stringByAppendingPathComponent:@"AssetData"];
	[self loadFontForPath:fontPath];
}

- (void)unloadFont:(LSFontAsset *)fontAsset {
	NSString *fontPath = [[self.class.fontBasePath stringByAppendingPathComponent:[self pathForFontAsset:fontAsset]] stringByAppendingPathComponent:@"AssetData"];
	[self unloadFontForPath:fontPath];
}

- (BOOL)isFontDownloaded:(LSFontAsset *)fontAsset {
	return [[NSFileManager defaultManager] fileExistsAtPath:[self.class.fontBasePath stringByAppendingPathComponent:[self pathForFontAsset:fontAsset]]];
}

- (LSFontAsset *)fontAssetContaingFontWithName:(NSString *)fontName {
	__block LSFontAsset *result = nil;
	[self.fontAssets enumerateObjectsUsingBlock:^(LSFontAsset *fontAsset, NSUInteger idx, BOOL *stop) {
		NSIndexSet *indexSet = [fontAsset.infoList indexesOfObjectsPassingTest:^BOOL(LSFontInfo *fontInfo, NSUInteger idx, BOOL *stop) {
			return [fontInfo.name isEqualToString:fontName];
		}];
		if (indexSet.count > 0) {
			result = fontAsset;
			stop = YES;
		}
	}];
	return result;
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
