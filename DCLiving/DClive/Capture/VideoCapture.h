//
//  VideoCapture.h
//  DCLiving
//
//  Created by point on 2017/12/20.
//  Copyright © 2017年 point. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VideoCapture : NSObject

- (void)startCapture:(UIView *)preview;

- (void)stopCapture;


@end
