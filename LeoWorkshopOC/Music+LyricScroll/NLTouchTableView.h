//
//  NLTouchTableView.h
//  LeoWorkshopOC
//
//  Created by leo on 2019/3/28.
//  Copyright © 2019 leo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol NLTouchTableViewDelegate <NSObject>
@optional
- (void)tableView:(UITableView *)tableView
     touchesBegan:(NSSet *)touches
        withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView
 touchesCancelled:(NSSet *)touches
        withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView
     touchesEnded:(NSSet *)touches
        withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView
     touchesMoved:(NSSet *)touches
        withEvent:(UIEvent *)event;
@end

@interface NLTouchTableView : UITableView {
    @private __weak id _touchTableDelegete;
}
@property (nonatomic, weak) id<NLTouchTableViewDelegate> touchTableDelegete;
@end

NS_ASSUME_NONNULL_END
