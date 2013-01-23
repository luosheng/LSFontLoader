//
//  LSFontLoader.m
//  LSFontLoader
//
//  Created by Luo Sheng on 13-1-23.
//  Copyright (c) 2013年 Luo Sheng. All rights reserved.
//

#import "LSFontLoader.h"
#import "LSFontInfo.h"

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
			LSFontInfo *info = [[LSFontInfo alloc] initWithDictionary:obj];
			[array addObject:info];
		}];
		self.fontInfoList = [array copy];
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id propertyList) {
		
	}];
	[operation start];
}

@end
