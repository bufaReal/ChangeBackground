//
//  UIImage+changeColor.h
//  ChangeBackground
//
//  Created by 孙树港 on 2020/2/24.
//  Copyright © 2020 ClassroomM. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (changeColor)

- (UIImage *)floodFillImage:(UIColor *)newColor fromePoint:(CGPoint)startPoint;

@end

NS_ASSUME_NONNULL_END
