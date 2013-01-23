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

- (void)downloadFont:(LSFontAsset *)fontAsset {
	NSURL *downloadURL = fontAsset.downloadURL;
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:downloadURL]];
	NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:downloadURL.lastPathComponent];
	operation.outputStream = [NSOutputStream outputStreamToFileAtPath:tempPath append:NO];
	operation.completionBlock = ^{
		LSFontInfo *fontInfo = fontAsset.infoList.lastObject;
		NSString *destinationPath = [self.fontPath stringByAppendingPathComponent:fontInfo.familyName];
		[SSZipArchive unzipFileAtPath:tempPath toDestination:destinationPath];
	};
	[operation start];
}

- (void)loadFontForFamilyName:(NSString *)familyName {
	NSString *fontSearchPath = [[self.fontPath stringByAppendingPathComponent:familyName] stringByAppendingPathComponent:@"AssetData"];
	NSArray *fontNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fontSearchPath error:nil];
	if (fontNames) {
		NSString *fontName = fontNames.lastObject;
		NSURL *fontURL = [NSURL fileURLWithPath:[fontSearchPath stringByAppendingPathComponent:fontName]];
		CFErrorRef error;
		if (!CTFontManagerRegisterFontsForURL((__bridge CFURLRef)(fontURL), kCTFontManagerScopeProcess, &error)) {
			CFStringRef errorDescription = CFErrorCopyDescription(error);
			NSLog(@"Failed to load font: %@", errorDescription);
			CFRelease(errorDescription);
		}
	}
}

- (void)loadFont:(LSFontAsset *)fontAsset {
	LSFontInfo *fontInfo = fontAsset.infoList.lastObject;
	[self loadFontForFamilyName:fontInfo.familyName];
}

- (BOOL)isFontDownloaded:(LSFontAsset *)fontAsset {
	LSFontInfo *fontInfo = fontAsset.infoList.lastObject;
	return [[NSFileManager defaultManager] fileExistsAtPath:[self.fontPath stringByAppendingPathComponent:fontInfo.familyName]];
}

@end
