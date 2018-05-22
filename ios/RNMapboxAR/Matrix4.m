//
//  Matrix4.m
//  RNLocateTest
//
//  Created by Dave Prukop on 4/26/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "Matrix4.h"

@interface Matrix4()

@property (nonatomic, strong) NSArray<NSNumber *> *elements;

@end

@implementation Matrix4

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.elements = [NSArray arrayWithObjects:
                     [NSNumber numberWithFloat:1.f], [NSNumber numberWithFloat:0.f], [NSNumber numberWithFloat:0.f], [NSNumber numberWithFloat:0.f],
                     [NSNumber numberWithFloat:0.f], [NSNumber numberWithFloat:1.f], [NSNumber numberWithFloat:0.f], [NSNumber numberWithFloat:0.f],
                     [NSNumber numberWithFloat:0.f], [NSNumber numberWithFloat:0.f],[NSNumber numberWithFloat:1.f], [NSNumber numberWithFloat:0.f],
                     [NSNumber numberWithFloat:0.f], [NSNumber numberWithFloat:0.f],[NSNumber numberWithFloat:0.f], [NSNumber numberWithFloat:1.f],
                     nil];
  }
  return self;
}

- (float)get:(NSUInteger)index
{
  return [[self.elements objectAtIndex:index] floatValue];
}

@end
