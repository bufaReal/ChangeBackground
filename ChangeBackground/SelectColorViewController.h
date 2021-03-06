//
//  SelectColorViewController.h
//  ChangeBackground
//
//  Created by 孙树港 on 2020/2/22.
//  Copyright © 2020 ClassroomM. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SelectColorViewController : UIViewController

@property (copy,nonatomic,readwrite)void (^MyBlock)(UIColor * color);
@property (copy, nonatomic) void (^MyTolorance)(NSUInteger tolorance);

@end

NS_ASSUME_NONNULL_END
