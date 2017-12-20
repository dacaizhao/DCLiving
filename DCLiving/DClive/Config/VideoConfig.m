//
//  VideoConfig.m
//  DCLiving
//
//  Created by point on 2017/12/20.
//  Copyright © 2017年 point. All rights reserved.
//

#import "VideoConfig.h"

@implementation VideoConfig

+ (instancetype)defaultConfig {
    VideoConfig *config = [[self alloc] init];
    config.bitrate = 800*1024;
    config.fps = 30;
    config.keyframeInterval = 30;
    return config;
}

@end
