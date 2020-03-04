//
//  ViewController.m
//  ChangeBackground
//
//  Created by 孙树港 on 2020/2/19.
//  Copyright © 2020 ClassroomM. All rights reserved.
//

#import "ViewController.h"
#import <YYWebImage.h>
#import "ChangeColorImage.h"
#import "SelectColorViewController.h"
#import "ChangeSizeViewController.h"

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *editImageView;
@property (weak, nonatomic) IBOutlet UITextField *urlTextFeild;

@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) UIColor *changeColor;

@end

@implementation ViewController
{
    ChangeColorImage *myImage;
    NSUInteger myTolorance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.editImageView.image = [ChangeColorImage imageNamed:@"a38c06590bad8ed04bf11109f2577d218c6e1d4d.png"];
    self->myImage = [[ChangeColorImage  alloc] initWithData:UIImagePNGRepresentation(self.editImageView.image)];
    [ChangeColorImage redoImage:myImage];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    
    __block ChangeColorImage *tmpImage = [[ChangeColorImage  alloc] initWithData:UIImagePNGRepresentation(self.editImageView.image)];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        tmpImage.MyNewColor = self.changeColor;
        tmpImage.startPoint = point;
        tmpImage.tolorance = self ->myTolorance;
        self->myImage = [tmpImage changeColor];
        [ChangeColorImage redoImage:self->myImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.editImageView.image = self->myImage;
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
- (IBAction)shareAction:(UIBarButtonItem *)sender {
    NSArray *activityItems = @[self->myImage];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityVC animated:TRUE completion:nil];
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
        self.editImageView.image = image;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  // segue.identifier：获取连线的ID
  if ([segue.identifier isEqualToString:@"ColorIdentifier"]) {
    // segue.destinationViewController：获取连线时所指的界面（VC）
      
      SelectColorViewController *vc = segue.destinationViewController;
      vc.MyBlock = ^(UIColor * _Nonnull color) {
          if (color) {
              self.changeColor = color;
          }
      };
    
      vc.MyTolorance = ^(NSUInteger tolorance) {
          self->myTolorance = tolorance;
      };
  }
    
    if ([segue.identifier isEqualToString:@"changeSizeIdentifier"]) {
        ChangeSizeViewController *vc = segue.destinationViewController;
        vc.sizeImage = self->myImage;
    }
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

- (UIColor *)changeColor
{
    if (!_changeColor) {
        _changeColor = [UIColor redColor];
    }
    return _changeColor;
}

@end
