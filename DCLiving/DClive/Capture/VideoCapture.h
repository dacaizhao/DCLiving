//
//  VideoCapture.h
//  DCLiving
//
//  Created by point on 2017/12/20.
//  Copyright © 2017年 point. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class VideoCapture;
@protocol VideoCaptureDeleagte <NSObject>
- (void)capture:(VideoCapture *)capture videoBuffer:(CMSampleBufferRef)videoBuffer;
- (void)capture:(VideoCapture *)capture audioBuffer:(CMSampleBufferRef)videoBuffer;
@end


@interface VideoCapture : NSObject

@property (nonatomic,weak) id<VideoCaptureDeleagte> delegate;

- (void)startCapture:(UIView *)preview;

- (void)stopCapture;


@end
