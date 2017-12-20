//
//  VideoCapture.m
//  DCLiving
//
//  Created by point on 2017/12/20.
//  Copyright © 2017年 point. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "VideoCapture.h"

@interface VideoCapture () <AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>

@property (nonatomic, weak) AVCaptureSession *captureSession; //捕捉会话
@property (nonatomic , strong) AVCaptureDeviceInput *captureVideoDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (nonatomic , strong) AVCaptureDeviceInput *captureAudioDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (nonatomic , strong) AVCaptureAudioDataOutput *captureAudioOutput; //输出
@property (nonatomic , strong) AVCaptureVideoDataOutput *captureVideoOutput; //输出

/** 预览图层 */
@property (nonatomic, weak) AVCaptureVideoPreviewLayer *previewLayer;

/** 捕捉画面执行的线程队列 */
@property (nonatomic, strong) dispatch_queue_t captureVideoQueue; //视频
@property (nonatomic, strong) dispatch_queue_t captureAudioQueue; //音频

@end

@implementation VideoCapture 

- (void)startCapture:(UIView *)preview
{
    
    
    // 1.创建捕捉会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPreset1280x720;
    self.captureSession = session;
    
    // 2.设置输入设备
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    NSError *error = nil;
    self.captureVideoDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoDevice error:&error];
    self.captureAudioDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:&error];
    if ([session canAddInput:self.captureVideoDeviceInput]) {
        [session addInput:self.captureVideoDeviceInput];
    }
    if ([session canAddInput:self.captureAudioDeviceInput]) {
        [session addInput:self.captureAudioDeviceInput];
    }
    
    // 3.添加输出设备
    self.captureVideoOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.captureAudioOutput = [[AVCaptureAudioDataOutput alloc] init];
    
    self.captureVideoQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.captureAudioQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [self.captureVideoOutput setSampleBufferDelegate:self queue:self.captureVideoQueue];
    [self.captureAudioOutput setSampleBufferDelegate:self queue:self.captureAudioQueue];
    [session addOutput: self.captureVideoOutput];
    [session addOutput: self.captureAudioOutput];
    
    // 设置录制视频的方向
    AVCaptureConnection *connection = [self.captureVideoOutput connectionWithMediaType:AVMediaTypeVideo];
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    // 4.添加预览图层
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    previewLayer.frame = preview.bounds;
    [preview.layer insertSublayer:previewLayer atIndex:0];
    self.previewLayer = previewLayer;
    
    // 5.开始捕捉
    [self.captureSession startRunning];
}

- (void)stopCapture {
    [self.captureSession stopRunning];
    [self.previewLayer removeFromSuperlayer];
    
}

#pragma mark - 获取到数据
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (captureOutput == self.captureVideoOutput) {
        NSLog(@"视频%@",[NSThread currentThread]);
        
    }else {
        NSLog(@"声音%@",[NSThread currentThread]);
    }
}

@end
