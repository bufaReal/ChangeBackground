//
//  ChangeColorImage.h
//  ChangeBackground
//
//  Created by 孙树港 on 2020/2/29.
//  Copyright © 2020 ClassroomM. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChangeColorImage : UIImage

@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) NSInteger tolorance;
@property (nonatomic, strong) UIColor* MyNewColor;
- (ChangeColorImage *)changeColor;
+(void)redoImage:(ChangeColorImage *)result;
+ (ChangeColorImage *)revokeLastImage;

@end

NS_ASSUME_NONNULL_END
