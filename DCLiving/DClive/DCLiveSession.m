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
#import "AACEncoder.h"
#import "RtmpManager.h"

@interface DCLiveSession ()<H264EncoderDeleagte,VideoCaptureDeleagte,AACEncoderDeleagte>

@property (nonatomic,strong) VideoCapture *videoCapture; //音视捕捉
@property (nonatomic,strong) H264Encoder *h264Encoder; //视频硬编
@property (nonatomic,strong) AACEncoder *aacEncoder; //音频硬编
@property (nonatomic,strong) NSFileHandle *fileHandle;

@end

@implementation DCLiveSession

+ (instancetype)defultSession{
    DCLiveSession *session = [[self alloc] init];
    return session;
}

- (void)startCapture:(UIView *)preview {
    [self.videoCapture startCapture:preview];
    [self setupFileHandle];
    self.videoCapture.delegate = self;
    self.h264Encoder.delegate = self;
    self.aacEncoder.delegate = self;
    
   // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[RtmpManager getInstance]startRtmpConnect];
   // });
}

- (void)stopCapture {
    [self.videoCapture stopCapture];
    [self.h264Encoder endEncode];
    [self.aacEncoder endEncode];
    [[RtmpManager getInstance]stopRtmpConnect];
}

#pragma mark - 捕获到的音频
- (void)capture:(VideoCapture *)capture audioBuffer:(CMSampleBufferRef)audioBuffer {
   // [self.aacEncoder encodeAudioData:audioBuffer timeStamp:0];
}

#pragma mark - 捕获到的视频
- (void)capture:(VideoCapture *)capture videoBuffer:(CMSampleBufferRef)videoBuffer {
    [self.h264Encoder encodeVideoData:videoBuffer timeStamp:0];
}

#pragma mark - 视频的编码
- (void)h264Encoder:(H264Encoder *)encoder didEncodeFrame:(NSData *)data timestamp:(uint64_t)timestamp isKeyFrame:(BOOL)isKeyFrame {
    
    //[[RtmpManager getInstance] send_rtmp_video:(unsigned char *)[data bytes] andLength:(uint32_t)[data length]];
    NSLog(@"ddd%s",(unsigned char *)[data bytes]);
}
//pps图像参数集 I帧的详情  sps序列参数集
- (void)h264Encoder:(H264Encoder *)encoder didGetSps:(NSData *)spsData pps:(NSData *)ppsData timestamp:(uint64_t)timestamp {
  
    
    //
     NSLog(@"vvv%s",(unsigned char *)[spsData bytes]);
}

#pragma mark - 音频的编码
- (void)aacEncoder:(AACEncoder *)encoder didEncodeBuffer:(NSData *)data timestamp:(uint64_t)timestamp {
    //[self.fileHandle writeData:data];
}



- (void)setupFileHandle {
    // 1.获取沙盒路径
    NSString *file = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"zhaodacai.aac"];
    
    // 2.如果原来有文件,则删除
    [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    [[NSFileManager defaultManager] createFileAtPath:file contents:nil attributes:nil];
    
    // 3.创建对象
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:file];
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

- (AACEncoder *)aacEncoder {
    if (!_aacEncoder) {
        _aacEncoder = [[AACEncoder alloc]init];
    }
    return _aacEncoder;
}


@end
