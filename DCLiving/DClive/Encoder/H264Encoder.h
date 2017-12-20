//
//  H264Encoder.h
//  DCLiving
//
//  Created by point on 2017/12/20.
//  Copyright © 2017年 point. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import "VideoConfig.h"


@class  H264Encoder;
@protocol H264EncoderDeleagte <NSObject>

- (void)h264Encoder:(H264Encoder *)encoder didGetSps:(NSData *)spsData pps:(NSData *)ppsData timestamp:(uint64_t)timestamp;

- (void)h264Encoder:(H264Encoder *)encoder didEncodeFrame:(NSData *)data timestamp:(uint64_t)timestamp isKeyFrame:(BOOL)isKeyFrame;

@end

@interface H264Encoder : NSObject

@property (nonatomic,weak) id<H264EncoderDeleagte> delegate;

@property (nonatomic,strong) VideoConfig *config;



- (void)encodeVideoData:(CMSampleBufferRef)pixelBuffer timeStamp:(uint64_t)timeStamp;

@end
