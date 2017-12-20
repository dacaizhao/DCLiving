//
//  DCLiveSession.m
//  DCLiving
//
//  Created by point on 2017/12/20.
//  Copyright © 2017年 point. All rights reserved.
//

#import "DCLiveSession.h"
#import "VideoCapture.h"
#import "H264Encoder.h"

@interface DCLiveSession ()<H264EncoderDeleagte,VideoCaptureDeleagte>

@property (nonatomic,strong) VideoCapture *videoCapture; //视频捕捉
@property (nonatomic,strong) H264Encoder *h264Encoder;

@end

@implementation DCLiveSession

+ (instancetype)defultSession{
    DCLiveSession *session = [[self alloc] init];
    return session;
}

- (void)startCapture:(UIView *)preview {
    [self.videoCapture startCapture:preview];
    self.videoCapture.delegate = self;
    self.h264Encoder.delegate = self;
    
}

- (void)stopCapture {
    [self.videoCapture stopCapture];
}

#pragma mark - 捕获到的音频
- (void)capture:(VideoCapture *)capture audioBuffer:(CMSampleBufferRef)videoBuffer {
}

#pragma mark - 捕获到的视频
- (void)capture:(VideoCapture *)capture videoBuffer:(CMSampleBufferRef)videoBuffer {
    [self.h264Encoder encodeVideoData:videoBuffer timeStamp:0];
}

- (void)h264Encoder:(H264Encoder *)encoder didEncodeFrame:(NSData *)data timestamp:(uint64_t)timestamp isKeyFrame:(BOOL)isKeyFrame {
    NSLog(@"111");
}

- (void)h264Encoder:(H264Encoder *)encoder didGetSps:(NSData *)spsData pps:(NSData *)ppsData timestamp:(uint64_t)timestamp {
    NSLog(@"222");
}




- (VideoCapture *)videoCapture {
    if (!_videoCapture) {
        _videoCapture = [[VideoCapture alloc]init];
    }
    return _videoCapture;
}

- (H264Encoder *)h264Encoder {
    if (!_h264Encoder) {
        _h264Encoder = [[H264Encoder alloc]init];
        _h264Encoder.config = _videoConfig;
    }
    return _h264Encoder;
}


@end
