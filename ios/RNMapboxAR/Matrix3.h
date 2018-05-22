//
//  Matrix3.h
//  RNLocateTest
//
//  Created by Dave Prukop on 4/26/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Matrix4.h"

@interface Matrix3 : NSObject

- (instancetype)initWithElements:(NSArray<NSNumber *> *)elements;
+ (Matrix3 *)getNormalMatrix:(Matrix4 *)matrix4;
- (float)get:(NSUInteger)index;
- (void)inverse;
- (void)transpose;

@end
