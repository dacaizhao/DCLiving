//
//  DCLiveSession.m
//  DCLiving
//
//  Created by point on 2017/12/20.
//  Copyright © 2017年 point. All rights reserved.
//

#import "DCLiveSession.h"
#import "VideoCapture.h"

@interface DCLiveSession ()

@property (nonatomic,strong) VideoCapture *videoCapture;

@end

@implementation DCLiveSession

+ (instancetype)defultSession{
    DCLiveSession *session = [[self alloc] init];
    return session;
}

- (void)startCapture:(UIView *)preview {
    [self.videoCapture startCapture:preview];
}

- (void)stopCapture {
    [self.videoCapture stopCapture];
}

- (VideoCapture *)videoCapture {
    if (!_videoCapture) {
        _videoCapture = [[VideoCapture alloc]init];
    }
    return _videoCapture;
}

@end
