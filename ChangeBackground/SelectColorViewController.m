//
//  SelectColorViewController.m
//  ChangeBackground
//
//  Created by 孙树港 on 2020/2/22.
//  Copyright © 2020 ClassroomM. All rights reserved.
//

#import "SelectColorViewController.h"

@interface SelectColorViewController ()

@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (nonatomic, strong) UIColor *selectColor;
@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;
@property (weak, nonatomic) IBOutlet UISlider *alphaSlider;
@property (weak, nonatomic) IBOutlet UITextField *toloranceTextField;

@end

@implementation SelectColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.colorView.backgroundColor = [UIColor colorWithRed:self.redSlider.value / 255.0 green:self.greenSlider.value / 255.0 blue:self.blueSlider.value / 255.0 alpha:self.alphaSlider.value];
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.MyBlock(self.colorView.backgroundColor);
    self.MyTolorance([self.toloranceTextField.text intValue]);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}
- (IBAction)redAction:(id)sender
{
    self.colorView.backgroundColor = [UIColor colorWithRed:self.redSlider.value / 255.0 green:self.greenSlider.value / 255.0 blue:self.blueSlider.value / 255.0 alpha:self.alphaSlider.value];
}
- (IBAction)greenAction:(id)sender
{
    self.colorView.backgroundColor = [UIColor colorWithRed:self.redSlider.value / 255.0 green:self.greenSlider.value / 255.0 blue:self.blueSlider.value / 255.0 alpha:self.alphaSlider.value];
}
- (IBAction)blueAction:(id)sender
{
    self.colorView.backgroundColor = [UIColor colorWithRed:self.redSlider.value / 255.0 green:self.greenSlider.value / 255.0 blue:self.blueSlider.value / 255.0 alpha:self.alphaSlider.value];
}
- (IBAction)alaphaAction:(id)sender
{
    self.colorView.backgroundColor = [UIColor colorWithRed:self.redSlider.value / 255.0 green:self.greenSlider.value / 255.0 blue:self.blueSlider.value / 255.0 alpha:self.alphaSlider.value];
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
