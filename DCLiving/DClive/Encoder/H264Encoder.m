//
//  H264Encoder.m
//  DCLiving
//
//  Created by point on 2017/12/20.
//  Copyright © 2017年 point. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "H264Encoder.h"
#import "RtmpManager.h"

@interface H264Encoder ()

/** 记录当前的帧数 */
@property (nonatomic, assign) NSInteger frameID;

/** 编码会话 */
@property (nonatomic, assign) VTCompressionSessionRef compressionSession;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@end

@implementation H264Encoder

- (instancetype)init {
    if (self = [super init]) {
        [self setupVideoSession];
        [self setupFileHandle];
    }
    return self;
}

- (void)encodeVideoData:(CMSampleBufferRef)pixelBuffer timeStamp:(uint64_t)timeStamp {
    // 1.将sampleBuffer转成imageBuffer
    CVImageBufferRef imageBuffer = (CVImageBufferRef)CMSampleBufferGetImageBuffer(pixelBuffer);
    
    // 2.根据当前的帧数,创建CMTime的时间
    CMTime presentationTimeStamp = CMTimeMake(self.frameID++, 1000);
    VTEncodeInfoFlags flags;
    
    // 3.开始编码该帧数据
    OSStatus statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                          imageBuffer,
                                                          presentationTimeStamp,
                                                          kCMTimeInvalid,
                                                          NULL, (__bridge void * _Nullable)(self), &flags);
    if (statusCode == noErr) {
        //NSLog(@"H264: VTCompressionSessionEncodeFrame Success");
    }
}

/**
 *配置
 */
- (void)setupVideoSession {
    // 1.用于记录当前是第几帧数据(画面帧数非常多)
    self.frameID = 0;
    
    // 2.录制视频的宽度&高度
    int width = [UIScreen mainScreen].bounds.size.width;
    int height = [UIScreen mainScreen].bounds.size.height;
    
    // 3.创建CompressionSession对象,该对象用于对画面进行编码
    // kCMVideoCodecType_H264 : 表示使用h.264进行编码
    // didCompressH264 : 当一次编码结束会在该函数进行回调,可以在该函数中将数据,写入文件中
    VTCompressionSessionCreate(NULL, width, height, kCMVideoCodecType_H264, NULL, NULL, NULL, didCompressH264, (__bridge void *)(self),  &_compressionSession);
    
    // 4.设置实时编码输出（直播必然是实时输出,否则会有延迟）
    VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
    
    // 5.设置期望帧率(每秒多少帧,如果帧率过低,会造成画面卡顿)
    int fps = _config.fps;
    CFNumberRef  fpsRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &fps);
    VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_ExpectedFrameRate, fpsRef);
    
    
    // 6.设置码率(码率: 编码效率, 码率越高,则画面越清晰, 如果码率较低会引起马赛克 --> 码率高有利于还原原始画面,但是也不利于传输)
    int bitRate = _config.bitrate;
    CFNumberRef bitRateRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitRate);
    VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_AverageBitRate, bitRateRef);
    NSArray *limit = @[@(bitRate * 1.5/8), @(1)];
    VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_DataRateLimits, (__bridge CFArrayRef)limit);
    
    // 7.设置关键帧（GOPsize)间隔
    int frameInterval = _config.keyframeInterval;
    CFNumberRef  frameIntervalRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &frameInterval);
    VTSessionSetProperty(self.compressionSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, frameIntervalRef);
    
    // 8.基本设置结束, 准备进行编码
    VTCompressionSessionPrepareToEncodeFrames(self.compressionSession);
}

/**
 *编码完成回调
 */
void didCompressH264(void *outputCallbackRefCon, void *sourceFrameRefCon, OSStatus status, VTEncodeInfoFlags infoFlags, CMSampleBufferRef sampleBuffer) {
    
    // 1.判断状态是否等于没有错误
    if (status != noErr) {
        return;
    }
    
    // 2.根据传入的参数获取对象
    H264Encoder* encoder = (__bridge H264Encoder*)outputCallbackRefCon;
    
    // 3.判断是否是关键帧
    bool isKeyframe = !CFDictionaryContainsKey( (CFArrayGetValueAtIndex(CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true), 0)), kCMSampleAttachmentKey_NotSync);
    // 判断当前帧是否为关键帧
    // 获取sps & pps数据
    if (isKeyframe)
    {
        // 获取编码后的信息（存储于CMFormatDescriptionRef中）
        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
        
        // 获取SPS信息
        size_t sparameterSetSize, sparameterSetCount;
        const uint8_t *sparameterSet;
        CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sparameterSet, &sparameterSetSize, &sparameterSetCount, 0 );
        
        // 获取PPS信息
        size_t pparameterSetSize, pparameterSetCount;
        const uint8_t *pparameterSet;
        CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pparameterSet, &pparameterSetSize, &pparameterSetCount, 0 );
        
        // 装sps/pps转成NSData，以方便写入文件
        //NSData *sps = [NSData dataWithBytes:sparameterSet length:sparameterSetSize];
        //NSData *pps = [NSData dataWithBytes:pparameterSet length:pparameterSetSize];
        
        // 写入文件
        //[encoder gotSpsPps:sps pps:pps];
        [[RtmpManager getInstance] send_video_sps_pps:(unsigned char *)sparameterSet andSpsLength:(int)sparameterSetSize andPPs:(unsigned char *)pparameterSet andPPsLength:(int)pparameterSetSize];
    }
    
    // 获取数据块
    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t length, totalLength;
    char *dataPointer;
    OSStatus statusCodeRet = CMBlockBufferGetDataPointer(dataBuffer, 0, &length, &totalLength, &dataPointer);
    if (statusCodeRet == noErr) {
        size_t bufferOffset = 0;
        static const int AVCCHeaderLength = 4; // 返回的nalu数据前四个字节不是0001的startcode，而是大端模式的帧长度length
        
        // 循环获取nalu数据 0
        while (bufferOffset < totalLength - AVCCHeaderLength) {
            uint32_t NALUnitLength = 0;
            // Read the NAL unit length
            memcpy(&NALUnitLength, dataPointer + bufferOffset, AVCCHeaderLength);
            
            // 从大端转系统端
            NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);
            
            
            // unsigned char* nali =
           const void * ddd = dataPointer + bufferOffset + AVCCHeaderLength;
            char *d = (char *)ddd;
           
            //char p[] = "\x00\x00\x01";
            //strcat(p,d);
          
            
            
            
            
//            char str[512];
//            memset(str, 0, 512);
//            memcpy(str, p, strlen(p));
//            memcpy(str + strlen(d), d, strlen(d));
            
            
            const char bytes[] = "\x00\x00\x01";
            size_t length = (sizeof bytes) - 1; //string literals have implicit trailing '\0'
            NSMutableData *ByteHeader = [NSMutableData dataWithBytes:bytes length:length];
            
            
            
            NSData *ddata3 = [NSData dataWithBytes: d length:NALUnitLength];
            
            
            [ByteHeader appendData:ddata3];
            
              [encoder.fileHandle writeData:ByteHeader];
        
            
            //NSLog(@"===%s",d);
            
            //NSData* data = [[NSData alloc] initWithBytes:(dataPointer + bufferOffset + AVCCHeaderLength) length:NALUnitLength];
            //[encoder gotEncodedData:data isKeyFrame:isKeyframe];
            [[RtmpManager getInstance] send_rtmp_video:(char *)[ByteHeader bytes] andLength:NALUnitLength + length];
            
            // 移动到写一个块，转成NALU单元
            // Move to the next NAL unit in the block buffer
            bufferOffset += AVCCHeaderLength + NALUnitLength;
        }
    }
}


#pragma mark - 得到的sps pps
- (void)gotSpsPps:(NSData*)sps pps:(NSData*)pps
{
    // 1.拼接NALU的header
    //const char bytes[] = "\x00\x00\x00\x01";
    //size_t length = (sizeof bytes) - 1;
    //NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
    // 2.将NALU的头&NALU的体写入文件
    // [self.fileHandle writeData:ByteHeader];
    // [self.fileHandle writeData:sps];
    // [self.fileHandle writeData:ByteHeader];
    // [self.fileHandle writeData:pps];
     //如何你想测试h264 请按注释的代码
    if ([self.delegate respondsToSelector:@selector(h264Encoder:didGetSps:pps:timestamp:)]) {
        [self.delegate h264Encoder:self didGetSps:sps pps:pps timestamp:0];
    }
    
   // [[RtmpManager getInstance] send_video_sps_pps:(unsigned char *)[sps bytes] andSpsLength:(uint32_t)[sps length] andPPs:(unsigned char *)[pps bytes] andPPsLength:(uint32_t)[pps length]];
    
      // NSLog(@"2222");
    
}

#pragma mark - 普通帧数据
- (void)gotEncodedData:(NSData*)data isKeyFrame:(BOOL)isKeyFrame
{
    //NSLog(@"gotEncodedData %d", (int)[data length]);
    //if (self.fileHandle != NULL)
    //{
    //const char bytes[] = "\x00\x00\x00\x01";
    //size_t length = (sizeof bytes) - 1; //string literals have implicit trailing '\0'
    //NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
    //  [self.fileHandle writeData:ByteHeader];
    // [self.fileHandle writeData:data];
    //}
    //NSLog(@"1111");
    //[[RtmpManager getInstance] send_rtmp_video:(unsigned char *)[data bytes] andLength:(uint32_t)[data length]];
    
    
    //NSLog(@"==%s",(unsigned char *)[data bytes]);
    
    if ([self.delegate respondsToSelector:@selector(h264Encoder:didEncodeFrame:timestamp:isKeyFrame:)]) {
        [self.delegate h264Encoder:self didEncodeFrame:data timestamp:0 isKeyFrame:YES];
    }
}

- (void)endEncode {
    VTCompressionSessionCompleteFrames(self.compressionSession, kCMTimeInvalid);
    VTCompressionSessionInvalidate(self.compressionSession);
    CFRelease(self.compressionSession);
    self.compressionSession = NULL;
}

- (void)setupFileHandle {
    // 1.获取沙盒路径
    NSString *file = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"9527.h264"];
    
    // 2.如果原来有文件,则删除
    [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    [[NSFileManager defaultManager] createFileAtPath:file contents:nil attributes:nil];
    
    // 3.创建对象
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:file];
}
@end
