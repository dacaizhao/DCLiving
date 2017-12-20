//
//  ViewController.m
//  DCLiving
//
//  Created by point on 2017/12/20.
//  Copyright © 2017年 point. All rights reserved.
//

#import "ViewController.h"
#import "VideoCapture.h"


@interface ViewController ()

@property (nonatomic,strong) VideoCapture *videoCapture;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)start:(UIButton *)sender {
    [self.videoCapture startCapture:self.view];
}

- (IBAction)end:(UIButton *)sender {
    [self.videoCapture stopCapture];
}


- (VideoCapture *)videoCapture {
    if (!_videoCapture) {
        _videoCapture = [[VideoCapture alloc]init];
    }
    return _videoCapture;
}
@end
