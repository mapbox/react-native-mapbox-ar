//
//  Vector2.m
//  RNLocateTest
//
//  Created by Dave Prukop on 4/26/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "Vector2.h"

@implementation Vector2

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.x = 0.f;
    self.y = 0.f;
  }
  return self;
}

- (instancetype)initWithX:(float)x andY:(float)y
{
  self = [super init];
  if (self) {
    self.x = x;
    self.y = y;
  }
  return self;
}

- (Vector2 *)clone
{
  return [[Vector2 alloc] initWithX:self.x andY:self.y];
}

- (NSString *)toString
{
  return [NSString stringWithFormat:@"%0f %0f", self.x, self.y];
}

@end
