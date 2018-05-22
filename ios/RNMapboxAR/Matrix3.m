//
//  Matrix3.m
//  RNLocateTest
//
//  Created by Dave Prukop on 4/26/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "Matrix3.h"

@interface Matrix3()

+ (NSArray<NSNumber *> *)IDENTITY;
@property (nonatomic, strong) NSArray<NSNumber *> *elements;

@end

@implementation Matrix3

+ (NSArray<NSNumber *> *)IDENTITY
{
  return [NSArray arrayWithObjects:
          [NSNumber numberWithFloat:1.f], [NSNumber numberWithFloat:0.f], [NSNumber numberWithFloat:0.f],
          [NSNumber numberWithFloat:0.f], [NSNumber numberWithFloat:1.f], [NSNumber numberWithFloat:0.f],
          [NSNumber numberWithFloat:0.f], [NSNumber numberWithFloat:0.f], [NSNumber numberWithFloat:1.f],
          nil];
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.elements = [Matrix3 IDENTITY];
  }
  return self;
}

- (instancetype)initWithElements:(NSArray<NSNumber *> *)elements
{
  self = [super init];
  if (self) {
    self.elements = elements;
  }
  return self;
}

+ (Matrix3 *)getNormalMatrix:(Matrix4 *)matrix4
{
  Matrix3 *normalMatrix = [[Matrix3 alloc] initWithElements:[NSArray arrayWithObjects:
                                                             [NSNumber numberWithFloat:[matrix4 get:0]], [NSNumber numberWithFloat:[matrix4 get:4]], [NSNumber numberWithFloat:[matrix4 get:8]],
                                                             [NSNumber numberWithFloat:[matrix4 get:1]], [NSNumber numberWithFloat:[matrix4 get:5]], [NSNumber numberWithFloat:[matrix4 get:9]],
                                                             [NSNumber numberWithFloat:[matrix4 get:2]], [NSNumber numberWithFloat:[matrix4 get:6]], [NSNumber numberWithFloat:[matrix4 get:10]],
                                                             nil]];
  [normalMatrix inverse];
  [normalMatrix transpose];
  return normalMatrix;
}

- (float)get:(NSUInteger)index
{
  return [[self.elements objectAtIndex:index] floatValue];
}

- (void)inverse
{
  float n11 = [self get:0];
  float n21 = [self get:1];
  float n31 = [self get:2];
  
  float n12 = [self get:3];
  float n22 = [self get:4];
  float n32 = [self get:5];
  
  float n13 = [self get:6];
  float n23 = [self get:7];
  float n33 = [self get:8];
  
  float t11 = n33 * n22 - n32 * n23;
  float t12 = n32 * n13 - n33 * n12;
  float t13 = n23 * n12 - n22 * n13;
  
  float det = n11 * t11 + n21 * t12 + n31 * t13;
  
  if (det == 0) {
    self.elements = [Matrix3 IDENTITY];
    return;
  }
  
  float detInv = 1.f / det;
  
  self.elements = [NSArray arrayWithObjects:
                   [NSNumber numberWithFloat:t11 * detInv],
                   [NSNumber numberWithFloat:(n31 * n23 - n33 * n21) * detInv],
                   [NSNumber numberWithFloat:(n32 * n21 - n31 * n22) * detInv],
                   [NSNumber numberWithFloat:t12 * detInv],
                   [NSNumber numberWithFloat:(n33 * n11 - n31 * n13) * detInv],
                   [NSNumber numberWithFloat:(n31 * n12 - n32 * n11) * detInv],
                   [NSNumber numberWithFloat:t13 * detInv],
                   [NSNumber numberWithFloat:(n21 * n13 - n33 * n21) * detInv],
                   [NSNumber numberWithFloat:(n22 * n11 - n21 * n12) * detInv],
                   nil];
}

- (void)transpose
{
  NSNumber *tmp = [NSNumber numberWithFloat:0.f];
  NSMutableArray *mutableElements = [NSMutableArray arrayWithArray:self.elements];
  
  tmp = [self.elements objectAtIndex:1];
  [mutableElements setObject:[self.elements objectAtIndex:3] atIndexedSubscript:1];
  [mutableElements setObject:tmp atIndexedSubscript:3];
  
  tmp = [self.elements objectAtIndex:2];
  [mutableElements setObject:[self.elements objectAtIndex:6] atIndexedSubscript:2];
  [mutableElements setObject:tmp atIndexedSubscript:6];
  
  tmp = [self.elements objectAtIndex:5];
  [mutableElements setObject:[self.elements objectAtIndex:7] atIndexedSubscript:5];
  [mutableElements setObject:tmp atIndexedSubscript:7];
  
  self.elements = [NSArray arrayWithArray:mutableElements];
}

@end
