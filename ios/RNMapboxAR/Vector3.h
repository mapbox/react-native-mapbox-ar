//
//  Vector3.h
//  RNLocateTest
//
//  Created by Dave Prukop on 4/26/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Matrix3.h"
#import "Matrix4.h"

@interface Vector3 : NSObject

@property (assign) float x;
@property (assign) float y;
@property (assign) float z;

- (instancetype)initWithX:(float)x andY:(float)y andZ:(float)z;
- (void)copy:(Vector3 *)vector;
- (Vector3 *)clone;
- (void)subVectorWithA:(Vector3 *)a andB:(Vector3 *)b;
- (void)cross:(Vector3 *)vector;
- (void)add:(Vector3 *)vector;
- (float)length;
- (void)normalize;
- (void)applyMatrix3:(Matrix3 *)matrix;
- (void)applyMatrix4:(Matrix4 *)matrix;
- (NSString *)toString;

@end
