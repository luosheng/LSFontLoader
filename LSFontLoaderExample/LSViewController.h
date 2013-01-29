//
//  LSViewController.h
//  LSFontLoaderExample
//
//  Created by Luo Sheng on 13-1-23.
//  Copyright (c) 2013年 Luo Sheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSFontLoader.h"
#import "MBProgressHUD.h"

@interface LSViewController : UITableViewController {
	LSFontLoader *_fontLoader;
	MBProgressHUD *_HUD;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
