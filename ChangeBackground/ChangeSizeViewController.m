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
@property (weak, nonatomic) IBOutlet UIImageView *changeImageView;
@property (weak, nonatomic) IBOutlet UISlider *verticalSlider;
@property (weak, nonatomic) IBOutlet UILabel *changeValueLable;

@end

@implementation ChangeSizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.changeImageView.image = (UIImage *)self.sizeImage;
    self.verticalSlider.transform = CGAffineTransformMakeRotation(M_PI/2);
    // Do any additional setup after loading the view.
}

- (IBAction)verticalAction:(UISlider *)sender
{
    
}

- (IBAction)horizontalAction:(UISlider *)sender
{
    
}
- (IBAction)stepperAction:(UIStepper *)sender
{
    self.changeImageView.image = (ChangeColorImage *)[ChangeColorImage
                                  imageWithData:UIImagePNGRepresentation(self.sizeImage)
                                  scale:sender.value];
    [self.changeImageView sizeThatFits:self.changeImageView.image.size];
    self.changeValueLable.text = [NSString stringWithFormat:@"放大倍数%.1f", sender.value];
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
