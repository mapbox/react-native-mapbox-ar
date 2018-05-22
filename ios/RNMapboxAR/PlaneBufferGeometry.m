//
//  PlaneBufferGeometry.m
//  RNLocateTest
//
//  Created by Dave Prukop on 4/30/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "PlaneBufferGeometry.h"

@implementation PlaneBufferGeometry

- (instancetype)initWithWidth:(int)width andHeight:(int)height andWidthSegments:(int)widthSegments andHeightSegments:(int)heightSegments
{
  self = [super init];
  if (self) {
    self.width = width;
    self.height = height;
    self.widthSegments = widthSegments;
    self.heightSegments= heightSegments;
    
    int gridX = widthSegments;
    int gridY = heightSegments;
    
    int gridX1 = gridX + 1;
    int gridY1 = gridY + 1;
    
    float widthHalf = width / 2.f;
    float heightHalf = height / 2.f;
    
    float segmentWidth = width / gridX;
    float segmentHeight = height / gridY;
    
    [self createBufferWithName:@"index" andCapacity:gridX * gridY * 6];
    [self createBufferWithName:@"position" andCapacity:gridX1 * gridY1 * 3];
    [self createBufferWithName:@"normal" andCapacity:gridX1 * gridY1 * 3];
    [self createBufferWithName:@"uv" andCapacity:gridX1 * gridY1 * 2];
    
    for (int iy=0; iy<gridY1; iy++) {
      float y = iy * segmentHeight - heightHalf;
      
      for (int ix=0; ix<gridX1; ix++) {
        float x = ix * segmentWidth - widthHalf;
        
        [self.position put:[NSNumber numberWithFloat:x]];
        [self.position put:[NSNumber numberWithFloat:-y]];
        [self.position put:[NSNumber numberWithFloat:0.f]];
        
        [self.normal put:[NSNumber numberWithFloat:0.f]];
        [self.normal put:[NSNumber numberWithFloat:0.f]];
        [self.normal put:[NSNumber numberWithFloat:1.f]];
        
        float fGridX = (float)gridX;
        float fGridY = (float)gridY;
        
        [self.uv put:[NSNumber numberWithFloat:ix / fGridX]];
        [self.uv put:[NSNumber numberWithFloat:1.f - (iy / fGridY)]];
        
        if (iy < gridY && ix < gridX) {
          int a = ix + gridX1 * iy;
          int b = ix + gridX1 * (iy + 1);
          int c = (ix + 1) + gridX1 * (iy + 1);
          int d = (ix + 1) + gridX1 * iy;
          
          [self.index put:a];
          [self.index put:b];
          [self.index put:d];
          [self.index put:b];
          [self.index put:c];
          [self.index put:d];
        }
      }
    }
    
  }
  return self;
}

@end
