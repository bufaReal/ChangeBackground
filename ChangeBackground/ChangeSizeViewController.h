//
//  ChangeSizeViewController.h
//  ChangeBackground
//
//  Created by 孙树港 on 2020/3/3.
//  Copyright © 2020 ClassroomM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChangeColorImage;

NS_ASSUME_NONNULL_BEGIN

@interface ChangeSizeViewController : UIViewController

@property (nonatomic, strong) ChangeColorImage *sizeImage;
@property (nonatomic, copy)void (^MyPoint)(CGPoint point);
@property (nonatomic, strong) UIColor *lastColor;
@property (nonatomic, assign) NSInteger tolorance;

@end

NS_ASSUME_NONNULL_END
