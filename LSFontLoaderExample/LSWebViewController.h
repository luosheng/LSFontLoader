//
//  LSWebViewController.h
//  LSFontLoader
//
//  Created by Luo Sheng on 13-1-29.
//  Copyright (c) 2013年 Luo Sheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSFontInfo.h"

@interface LSWebViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) LSFontInfo *fontInfo;

@end
