//
//  ViewController.m
//  DCLiving
//
//  Created by point on 2017/12/20.
//  Copyright © 2017年 point. All rights reserved.
//

#import "ViewController.h"
#import "DCLiveSession.h"


@interface ViewController ()

@property (nonatomic,strong) DCLiveSession *liveSession;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    VideoConfig *videoConfig = [VideoConfig defaultConfig];
    self.liveSession.videoConfig = videoConfig;
    
}

- (IBAction)start:(UIButton *)sender {
    [self.liveSession startCapture:self.view];
}

- (IBAction)end:(UIButton *)sender {
    [self.liveSession stopCapture];
}


- (DCLiveSession *)liveSession {
    if (!_liveSession) {
        _liveSession = [DCLiveSession defultSession];
    }
    return _liveSession;
}
@end
