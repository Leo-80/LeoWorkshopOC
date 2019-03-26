//
//  NLOSSManageTestViewController.m
//  LeoWorkshopOC
//
//  Created by leo on 2019/3/24.
//  Copyright © 2019 leo. All rights reserved.
//

#import "NLOSSManageTestViewController.h"
#import "NLOSSManage.h"

@interface NLOSSManageTestViewController ()

@end

@implementation NLOSSManageTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [[NLOSSManage initOSSManage] downloadFileFromAliOSS];
    
    [[NLOSSManage initOSSManage] uploadFilesForAliOSS:@"/Users/leo/Documents/LeoWorkshopOC/LeoWorkshopOC/LrcParseTool/1553073016455.txt" savePath:@"video/1234567890"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
