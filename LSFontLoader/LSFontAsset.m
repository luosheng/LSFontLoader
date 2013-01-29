//
//  LSFontAsset.m
//  LSFontLoader
//
//  Created by Luo Sheng on 13-1-23.
//  Copyright (c) 2013年 Luo Sheng. All rights reserved.
//

#import "LSFontAsset.h"
#import "LSFontInfo.h"

@interface LSFontAsset ()

@property (nonatomic, strong) NSArray *infoList;

@end

@implementation LSFontAsset

- (id)initWithDictionary:(NSDictionary *)dictionary {
	self = [super init];
	if (self) {
		_info = dictionary;
	}
	return self;
}

- (NSURL *)downloadURL {
	NSString *baseURLString = _info[@"__BaseURL"];
	NSString *relativePathString = _info[@"__RelativePath"];
	return [NSURL URLWithString:[baseURLString stringByAppendingPathComponent:relativePathString]];
}

- (NSArray *)infoList {
	if (!_infoList) {
		NSMutableArray *list = [NSMutableArray array];
		[(NSArray *)_info[@"FontInfo"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[list addObject:[[LSFontInfo alloc] initWithDictionary:obj]];
		}];
		_infoList = [list copy];
	}
	return _infoList;
}

- (NSArray *)designLanguages {
	return _info[@"FontDesignLanguages"];
}

- (NSString *)familyName {
	LSFontInfo *info = self.infoList.lastObject;
	return info.familyName;
}

@end
