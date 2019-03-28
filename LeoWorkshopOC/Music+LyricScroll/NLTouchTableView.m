//
//  NLTouchTableView.m
//  LeoWorkshopOC
//
//  Created by leo on 2019/3/28.
//  Copyright © 2019 leo. All rights reserved.
//

#import "NLTouchTableView.h"

@implementation NLTouchTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
@synthesize touchTableDelegete = _touchDelegate;

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[self nextResponder] touchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
    if ([_touchDelegate conformsToProtocol:@protocol(NLTouchTableViewDelegate)] && [_touchDelegate respondsToSelector:@selector(tableView:touchesBegan:withEvent:)]) {
        [_touchDelegate tableView:self touchesBegan:touches withEvent:event];
    }
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    if ([_touchDelegate conformsToProtocol:@protocol(NLTouchTableViewDelegate)] && [_touchDelegate respondsToSelector:@selector(tableView:touchesMoved:withEvent:)]) {
        [_touchDelegate tableView:self touchesMoved:touches withEvent:event];
    }
}
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    if ([_touchDelegate conformsToProtocol:@protocol(NLTouchTableViewDelegate)] && [_touchDelegate respondsToSelector:@selector(tableView:touchesCancelled:withEvent:)]) {
        [_touchDelegate tableView:self touchesCancelled:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    if ([_touchDelegate conformsToProtocol:@protocol(NLTouchTableViewDelegate)] && [_touchDelegate respondsToSelector:@selector(tableView:touchesEnded:withEvent:)]) {
        [_touchDelegate tableView:self touchesEnded:touches withEvent:event];
    }
}
@end
