//
//  DCLiveSession.h
//  DCLiving
//
//  Created by point on 2017/12/20.
//  Copyright © 2017年 point. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VideoConfig.h"


@interface DCLiveSession : NSObject

@property (nonatomic,strong) VideoConfig *videoConfig; //视屏配置

+ (instancetype)defultSession;

- (void)startCapture:(UIView *)preview;

- (void)stopCapture;

@end
