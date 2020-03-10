//
//  ChangeSizeViewController.m
//  ChangeBackground
//
//  Created by 孙树港 on 2020/3/3.
//  Copyright © 2020 ClassroomM. All rights reserved.
//

#import "ChangeSizeViewController.h"
#import <Masonry.h>
#import "ChangeColorImage.h"

@interface ChangeSizeViewController ()

@property (strong, nonatomic) UIScrollView *sizeScroollView;
@property (strong, nonatomic) UIImageView *changeImageView;
@property (weak, nonatomic) IBOutlet UILabel *changeValueLable;
@property (weak, nonatomic) IBOutlet UILabel *clickPoint;
@property (weak, nonatomic) IBOutlet UISwitch *changeColor;
@property (weak, nonatomic) IBOutlet UILabel *isChangeColor;
@property (assign, nonatomic) CGPoint lastPoint;
@property (assign, nonatomic) CGFloat currentScale;

@end

@implementation ChangeSizeViewController
{
    ChangeColorImage *myImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sizeScroollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.sizeScroollView];
    [self.sizeScroollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).mas_offset(25);
        make.left.equalTo(self.view.mas_left).mas_offset(25);
        make.right.greaterThanOrEqualTo(self.view.mas_right).mas_offset(-25);
//        make.centerX.equalTo(self.view.mas_centerX).priorityHigh;
        make.bottom.greaterThanOrEqualTo(self.isChangeColor.mas_top).mas_offset(-10);
    }];
    
    self.changeImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    [self.sizeScroollView addSubview:self.changeImageView];
    self.changeImageView.userInteractionEnabled = YES;
    //添加点击手势
    UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAction:)];

    //点击几次后触发事件响应，默认为：1
    click.numberOfTapsRequired = 1;
    //需要几个手指点击时触发事件，默认：1
    click.numberOfTouchesRequired = 1;
    [self.changeImageView addGestureRecognizer:click];
    
    [self.changeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.sizeScroollView);
    }];
    self.changeImageView.image = (UIImage *)self.sizeImage;
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.lastPoint.x != 0 || self.lastPoint.y !=0) {
        self.MyPoint(self.lastPoint);
    }
}

- (IBAction)stepperAction:(UIStepper *)sender
{
    self.changeImageView.image = (ChangeColorImage *)[ChangeColorImage
                                  imageWithData:UIImagePNGRepresentation(self.sizeImage)
                                  scale:sender.value];
    self.currentScale = sender.value;
    self.changeValueLable.text = [NSString stringWithFormat:@"放大倍数%.1f", sender.value];
}
- (IBAction)revokeAction:(UIBarButtonItem *)sender
{
    ChangeColorImage *image =  [ChangeColorImage revokeLastImage];
    CGImageRef cgref = [image CGImage];
    CIImage *cim = [image CIImage];
    if (cim == nil && cgref == NULL)
    {
        return ;
    } else {
        self.changeImageView.image = image;
        self->myImage = image;
    }
}

#pragma mark action
// 单击手势
- (void)clickAction:(UITapGestureRecognizer *)gesture
{
    self.lastPoint = [gesture locationInView:self.sizeScroollView];
    //roundf四舍五入取整
    CGPoint clickPoint = CGPointMake(roundf(self.changeImageView.image.size.width / self.changeImageView.bounds.size.width * self.lastPoint.x * self.currentScale),
                                     roundf(self.changeImageView.image.size.height / self.changeImageView.bounds.size.height * self.lastPoint.y* self.currentScale));
    @try {
        if (self.changeColor.on) {
            __block ChangeColorImage *tmpImage = [[ChangeColorImage  alloc] initWithData:UIImagePNGRepresentation(self.changeImageView.image)];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                tmpImage.MyNewColor = self.lastColor;
                tmpImage.startPoint = clickPoint;
                tmpImage.tolorance = self.tolorance;
                self->myImage = [tmpImage changePonitColor];
                [ChangeColorImage redoImage:self->myImage];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.changeImageView.image = [UIImage imageWithData:UIImagePNGRepresentation(self->myImage) scale:self.currentScale];
                    // self->myImage;
                });
            });
        }
    } @catch (NSException *exception) {
        NSLog(@"捕获到异常：%@%@",exception.name, exception.reason);
    } @finally {
        
    }
    
    self.lastPoint = clickPoint;
    self.clickPoint.text = [NSString stringWithFormat:@"修改的位置x%.1f y%.1f", self.lastPoint.x, self.lastPoint.y];
    
    
//    NSLog(@"singleTapGesture%f-%f", point.x, point.y);
}

- (CGFloat)currentScale
{
    if (_currentScale == 0) {
        _currentScale = 1.f;
    }
    return _currentScale;
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
