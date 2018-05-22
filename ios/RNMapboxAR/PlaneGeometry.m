//
//  PlaneGeometry.m
//  RNLocateTest
//
//  Created by Dave Prukop on 4/30/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "PlaneGeometry.h"
#import "PlaneBufferGeometry.h"

@implementation PlaneGeometry

- (instancetype)initWithWidth:(int)width andHeight:(int)height andWidthSegments:(int)widthSegments andHeightSegments:(int)heightSegments
{
  self = [super init];
  if (self) {
    self.width = width;
    self.height = height;
    self.widthSegments = widthSegments;
    self.heightSegments= heightSegments;
    
    [self fromBufferGeometry:[[PlaneBufferGeometry alloc] initWithWidth:width andHeight:height andWidthSegments:widthSegments andHeightSegments:heightSegments]];
  }
  return self;
}

@end
