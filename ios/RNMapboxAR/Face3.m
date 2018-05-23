//
//  Face3.m
//  RNLocateTest
//
//  Created by Dave Prukop on 4/26/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "Face3.h"

@implementation Face3

- (instancetype)initWithA:(int)a andB:(int)b andC:(int)c andVertexNormals:(NSArray<Vector3 *> *)vertexNormals
{
  self = [super init];
  if (self) {
    self.a = a;
    self.b = b;
    self.c = c;
    self.normal = [[Vector3 alloc] init];
    self.vertexNormals = vertexNormals;
  }
  return self;
}

@end
