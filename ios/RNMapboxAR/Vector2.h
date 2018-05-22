//
//  Vector2.h
//  RNLocateTest
//
//  Created by Dave Prukop on 4/26/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Vector2 : NSObject

@property (assign) float x;
@property (assign) float y;

- (instancetype)initWithX:(float)x andY:(float)y;
- (Vector2 *)clone;
- (NSString *)toString;

@end
