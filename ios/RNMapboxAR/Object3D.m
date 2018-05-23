//
//  Object3D.m
//  RNLocateTest
//
//  Created by Dave Prukop on 4/27/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "Object3D.h"

@implementation Object3D

- (instancetype)initWithName:(NSString *)name
{
  self = [super init];
  if (self) {
    self.name = name;
    self.geometries = [[NSDictionary alloc] init];
  }
  return self;
}

- (void)addGeometry:(Geometry *)geometry withName:(NSString *)name
{
  NSMutableDictionary *localGeometries = [NSMutableDictionary dictionaryWithDictionary:self.geometries];
  [localGeometries setObject:geometry forKey:name];
  self.geometries = [NSDictionary dictionaryWithDictionary:localGeometries];
}

@end
