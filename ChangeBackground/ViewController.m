//
//  ViewController.m
//  ChangeBackground
//
//  Created by 孙树港 on 2020/2/19.
//  Copyright © 2020 ClassroomM. All rights reserved.
//

#import "ViewController.h"
#import <YYWebImage.h>
#import "UIImage+changeColor.h"

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *editImageView;
@property (weak, nonatomic) IBOutlet UITextField *urlTextFeild;

@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.editImageView.image = [UIImage imageNamed:@"2.jpg"];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
    
    //判断是否点击在图片上了
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.editImageView];
    if (![self.editImageView pointInside:point withEvent:event]) {
        NSLog(@"点远了");
        return;
    }
    
    //roundf四舍五入取整
    point.x = roundf(self.editImageView.image.size.width / self.editImageView.bounds.size.width * point.x);
    point.y = roundf(self.editImageView.image.size.height / self.editImageView.bounds.size.height * point.y);
    
    __block UIImage *tmpImage = self.editImageView.image;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        tmpImage = [tmpImage floodFillImage:[UIColor redColor] fromePoint:point];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.editImageView.image = tmpImage;
        });
    });
}
- (IBAction)sureAction:(id)sender
{
    NSURL *URL = [NSURL URLWithString:self.urlTextFeild.text];

    [self.editImageView yy_setImageWithURL:URL
                               placeholder:nil
                                   options:YYWebImageOptionSetImageWithFadeAnimation
                                  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        // 计算进度
        float progress = (float)receivedSize/expectedSize;
        NSLog(@"%f",progress);

    } transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
        NSLog(@"url is %@", url);
        return image;
    } completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        // 测试 : 是否是从磁盘加载的
        if (from == YYWebImageFromDiskCache) {
            NSLog(@"load from disk cache");
        }
        NSLog(@"%@", error);
    }];
    
}
- (IBAction)selectNativePhoto:(id)sender {
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
    
}
- (IBAction)takePhotoAction:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:
        UIImagePickerControllerSourceTypeCamera])
    {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else{
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

#pragma mark pickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.editImageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
}

#pragma mark lazy load
- (UIImagePickerController *)imagePickerController
{
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc]init];
        _imagePickerController.delegate = self;
        _imagePickerController.allowsEditing = YES;
    }
    return _imagePickerController;
}
@end
