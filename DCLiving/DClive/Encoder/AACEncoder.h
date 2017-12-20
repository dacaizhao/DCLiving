//
//  AACEncoder.h
//  DCLiving
//
//  Created by point on 2017/12/20.
//  Copyright © 2017年 point. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@class AACEncoder;
@protocol AACEncoderDeleagte <NSObject>

- (void)aacEncoder:(AACEncoder *)encoder didEncodeBuffer:(NSData *)data timestamp:(uint64_t)timestamp;

@end


@interface AACEncoder : NSObject

@property (nonatomic,weak) id<AACEncoderDeleagte> delegate;

- (void)encodeAudioData:(CMSampleBufferRef)sampleBuffer timeStamp:(uint64_t)timeStamp;

- (void)endEncode;

@end
