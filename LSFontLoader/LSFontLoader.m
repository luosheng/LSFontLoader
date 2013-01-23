//
//  LSFontLoader.m
//  LSFontLoader
//
//  Created by Luo Sheng on 13-1-23.
//  Copyright (c) 2013年 Luo Sheng. All rights reserved.
//

#import "LSFontLoader.h"

@implementation LSFontLoader

+ (instancetype)sharedLoader {
	static dispatch_once_t onceToken;
	static LSFontLoader *instance = nil;
	dispatch_once(&onceToken, ^{
    instance = [[LSFontLoader alloc] init];
	});
	return instance;
}

- (void)fetchManifest {
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mesu.apple.com/assets/com_apple_MobileAsset_Font/com_apple_MobileAsset_Font.xml"]];
	LSPropertyListRequestOperation *operation = [LSPropertyListRequestOperation propertyListRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id propertyList) {
		NSArray *assets = propertyList[@"Assets"];
		NSMutableArray *array = [NSMutableArray array];
		[assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			LSFontAsset *info = [[LSFontAsset alloc] initWithDictionary:obj];
			[array addObject:info];
		}];
		self.fontInfoList = [array copy];
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id propertyList) {
		
	}];
	[operation start];
}

- (void)downloadFont:(LSFontInfo *)fontInfo {
	NSURL *downloadURL = fontInfo.downloadURL;
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:downloadURL]];
	NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:downloadURL.lastPathComponent];
	operation.outputStream = [NSOutputStream outputStreamToFileAtPath:tempPath append:NO];
	[operation start];
}

@end
