//
//  NLLrcParseTestViewController.m
//  LeoWorkshopOC
//
//  Created by leo on 2019/3/24.
//  Copyright © 2019 leo. All rights reserved.
//

#import "NLLrcParseTestViewController.h"
#import "NLLrcParseTool.h"

@interface NLLrcParseTestViewController ()
@property (nonatomic, strong) UITextView * lrcTextView;
@end

@implementation NLLrcParseTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.lrcTextView];
    NSMutableString * lrcAllStr = [NSMutableString string];
    NSArray * lrcObjects = [[NLLrcParseTool initLrcParseTool] lrcToolWithLrcFile:@"1544888229409284" FileType:@"txt"];
    NSLog(@"lrcObjects : %@",lrcObjects);
    for (LrcObject * lrcOb in lrcObjects) {
        [lrcAllStr appendString:lrcOb.lrcStr];
    }
    _lrcTextView.text = lrcAllStr;
}
- (UITextView *)lrcTextView{
    if (!_lrcTextView) {
        _lrcTextView = [[UITextView alloc] init];
        _lrcTextView.frame = self.view.frame;
        _lrcTextView.font = [UIFont systemFontOfSize:16.0f];
        _lrcTextView.textColor = [UIColor blueColor];
        _lrcTextView.editable = NO;
    }
    return _lrcTextView;
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
