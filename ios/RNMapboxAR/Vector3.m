//
//  Vector3.m
//  RNLocateTest
//
//  Created by Dave Prukop on 4/26/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "Vector3.h"

@implementation Vector3

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.x = 0.f;
    self.y = 0.f;
    self.z = 0.f;
  }
  return self;
}

- (instancetype)initWithX:(float)x andY:(float)y andZ:(float)z
{
  self = [super init];
  if (self) {
    self.x = x;
    self.y = y;
    self.z = z;
  }
  return self;
}

- (void)copy:(Vector3 *)vector
{
  self.x = vector.x;
  self.y = vector.y;
  self.z = vector.z;
}

- (Vector3 *)clone
{
  return [[Vector3 alloc] initWithX:self.x andY:self.y andZ:self.z];
}

- (void)subVectorWithA:(Vector3 *)a andB:(Vector3 *)b
{
  self.x = a.x - b.x;
  self.y = a.y - b.y;
  self.z = a.z - b.z;
}

- (void)cross:(Vector3 *)vector
{
  float newX = self.y * vector.z - self.z * vector.y;
  float newY = self.z * vector.x - self.x * vector.z;
  float newZ = self.x * vector.y - self.y * vector.x;
  self.x = newX;
  self.y = newY;
  self.z = newZ;
}

- (void)add:(Vector3 *)vector
{
  self.x += vector.x;
  self.y += vector.y;
  self.z += vector.z;
}

- (float)length
{
  return sqrt(self.x * self.x + self.y * self.y + self.z * self.z);
}

- (void)normalize
{
  float len = [self length];
  float scalar = len > 0.f ? 1.f / len : 0.f;
  
  self.x *= scalar;
  self.y *= scalar;
  self.z *= scalar;
}

- (void)applyMatrix3:(Matrix3 *)matrix
{
  float x = self.x;
  float y = self.y;
  float z = self.z;
  
  self.x = [matrix get:0] * x + [matrix get:3] * y + [matrix get:6] * z;
  self.y = [matrix get:1] * x + [matrix get:4] * y + [matrix get:7] * z;
  self.z = [matrix get:2] * x + [matrix get:5] * y + [matrix get:8] * z;
}

- (void)applyMatrix4:(Matrix4 *)matrix
{
  float x = self.x;
  float y = self.y;
  float z = self.z;
  float w = 1.f / ([matrix get:3] * x + [matrix get:7] * y + [matrix get:11] * z + [matrix get:15]);
  
  self.x = ([matrix get:0] * x + [matrix get:4] * y + [matrix get:8] * z + [matrix get:12]) * w;
  self.y = ([matrix get:1] * x + [matrix get:5] * y + [matrix get:9] * z + [matrix get:13]) * w;
  self.z = ([matrix get:2] * x + [matrix get:6] * y + [matrix get:10] * z + [matrix get:14]) * w;
}

- (NSString *)toString
{
  return [NSString stringWithFormat:@"%f %f %f", self.x, self.y, self.z];
}

@end
