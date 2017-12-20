//
//  VideoConfig.h
//  DCLiving
//
//  Created by point on 2017/12/20.
//  Copyright © 2017年 point. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoConfig : NSObject

@property (nonatomic,assign) int bitrate; //码率默认800*1024

@property (nonatomic,assign) int fps; //默认30

@property (nonatomic,assign) int keyframeInterval; //帧率 默认30

+ (instancetype)defaultConfig;

@end
