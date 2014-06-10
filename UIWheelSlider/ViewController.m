//
//  ViewController.m
//  UIWheelSlider
//
//  Created by yuanfeng on 14-6-10.
//  Copyright (c) 2014年 yuanfeng. All rights reserved.
//

#import "ViewController.h"
#import "UIWheelSlider.h"

@interface ViewController ()
@property (nonatomic, strong) UILabel * valueLabel;
@property (nonatomic, strong) UIWheelSlider * wheelSlider;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self addBackgroundImage];
    
    self.wheelSlider = [[UIWheelSlider alloc] initWithFrame:CGRectMake(50, 100, 28, 300)];
    self.wheelSlider.value = 85;
    self.wheelSlider.maximumValue = 100;
    self.wheelSlider.minimumValue = 0;
    
    //    wheelSlider.maximumTintColor = [UIColor blueColor];
    //    wheelSlider.deltaRadian = M_PI/20;
    //    wheelSlider.continuous = NO;
    [self.wheelSlider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.wheelSlider];
    
    self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 50, 50, 30)];
    [self.valueLabel setText:[NSString stringWithFormat:@"%0.2f",self.wheelSlider.value]];
    [self.valueLabel setBackgroundColor:[UIColor clearColor]];
    [self.valueLabel setFont:[UIFont systemFontOfSize:14]];
    [self.valueLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.valueLabel];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)sliderValueDidChange:(id)sender{
    NSLog(@"sliderValueDidChange");
    [self.valueLabel setText:[NSString stringWithFormat:@"%0.2f",self.wheelSlider.value]];
}

-(void)addBackgroundImage{
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,0.0f,320.0f,568)];
    backImageView.contentMode = UIViewContentModeScaleAspectFit;
    backImageView.image = [UIImage imageNamed:@"backImage.jpg"];
    backImageView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:backImageView atIndex:0];
}

@end
