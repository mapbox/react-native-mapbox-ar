//
//  ObjFileExporter.m
//  RNLocateTest
//
//  Created by Dave Prukop on 5/2/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "ObjFileExporter.h"
#import "BufferGeometry.h"
#import "Geometry.h"
#import "Matrix3.h"
#import "Matrix4.h"
#import "Vector2.h"
#import "Vector3.h"
#import "ListUtils.h"

@interface ObjectFileWriter : NSObject

@property (nonatomic, strong) NSMutableData *objectFile;
@property (nonatomic, strong) NSMutableString *contentBuffer;

- (void)appendData:(NSArray<NSString *>*)data;
- (NSData *)getFile;

@end

@implementation ObjFileExporter

+ (NSData *)createFileWithObject3D:(Object3D *)object3D
{
  Matrix4 *WORLD_MATRIX = [[Matrix4 alloc] init];
  Matrix3 *NORMAL_WORLD_MATRIX = [Matrix3 getNormalMatrix:WORLD_MATRIX];
  
  ObjectFileWriter *writer = [[ObjectFileWriter alloc] init];
  
  [writer appendData:[NSArray arrayWithObject:[NSString stringWithFormat:@"o %@\n", object3D.name]]];
  
  int indexVert = 0;
  int indexNorm = 0;
  int indexUv = 0;
  
  NSMutableArray<NSString *> *line = [NSMutableArray arrayWithCapacity:3];
  [line setObject:@"" atIndexedSubscript:0];
  [line setObject:@"" atIndexedSubscript:1];
  [line setObject:@"\n" atIndexedSubscript:2];
  
  Vector3 *vector3 = [[Vector3 alloc] init];
  Vector2 *vector2 = [[Vector2 alloc] init];
  
  NSArray *geometriesKeys = [object3D.geometries allKeys];
  
  for (int keyIndex=0; keyIndex<[geometriesKeys count]; keyIndex++) {
    BufferGeometry *bufferGeometry = [[object3D.geometries objectForKey:[geometriesKeys objectAtIndex:keyIndex]] toBufferGeometry];
    
    int curVert = 0;
    int curNorm = 0;
    int curUv = 0;
    
    [line setObject:@"v " atIndexedSubscript:0];
    for (int i=0; i<[bufferGeometry.position size]; i+=3) {
      vector3.x = [bufferGeometry.position get:i];
      vector3.y = [bufferGeometry.position get:i+1];
      vector3.z = [bufferGeometry.position get:i+2];
      
      [vector3 applyMatrix4:WORLD_MATRIX];
      
      [line setObject:[vector3 toString] atIndexedSubscript:1];
      [writer appendData:line];
      
      curVert++;
    }
    
    [line setObject:@"vn " atIndexedSubscript:0];
    for (int i=0; i<[bufferGeometry.normal size]; i+=3) {
      vector3.x = [bufferGeometry.normal get:i];
      vector3.y = [bufferGeometry.normal get:i+1];
      vector3.z = [bufferGeometry.normal get:i+2];
      
      [vector3 applyMatrix3:NORMAL_WORLD_MATRIX];
      
      [line setObject:[vector3 toString] atIndexedSubscript:1];
      [writer appendData:line];
      
      curNorm++;
    }
    
    [line setObject:@"vt " atIndexedSubscript:0];
    for (int i=0; i<[bufferGeometry.uv size]; i+=2) {
      vector2.x = [bufferGeometry.uv get:i];
      vector2.y = [bufferGeometry.uv get:i+1];
      [line setObject:[vector2 toString] atIndexedSubscript:1];
      [writer appendData:line];
      
      curUv++;
    }
    
    NSMutableArray<NSString *> *face = [[NSMutableArray alloc] init];
    
    [line setObject:@"f " atIndexedSubscript:0];
    for (int i=0; i<[bufferGeometry.position size] / 3; i+=3) {
      for (int m=0; m<3; m++) {
        int j = i + m + 1;
        [face addObject:[NSString stringWithFormat:@"%d/%d/%d", indexVert+j, indexUv+j, indexNorm+j]];
      }
      NSString *faceStr = [ListUtils join:face withDelimiter:@" "];
      [line setObject:faceStr atIndexedSubscript:1];
      [writer appendData:line];
      [face removeAllObjects];
    }
    
    indexVert += curVert;
    indexNorm += curNorm;
    indexUv += curUv;
    
    [writer appendData:[NSArray arrayWithObject:@"\n"]];
  }
  
  return [writer getFile];
}

@end

@implementation ObjectFileWriter

static int BYTES_PER_CHAR = 11;
static int MAX_MB_IN_BUILDER_BYTES = 16 * 1000000;

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.contentBuffer = [[NSMutableString alloc] init];
    self.objectFile = [[NSMutableData alloc] init]; // FSUtils
  }
  return self;
}

- (void)appendData:(NSArray<NSString *>*)data
{
  for (int i=0; i<[data count]; i++) {
    [self.contentBuffer appendString:[data objectAtIndex:i]];
  }
//  if ([self shouldFlush]) {
//    [self writeToFile];
//  }
}

- (BOOL)shouldFlush
{
  return self.contentBuffer.length * BYTES_PER_CHAR >= MAX_MB_IN_BUILDER_BYTES;
}

- (void)writeToFile
{
  [self.objectFile appendData:[self.contentBuffer dataUsingEncoding:NSUTF8StringEncoding]];
  [self.contentBuffer setString:@""];
}

- (NSData *)getFile
{
  if (self.contentBuffer.length > 0) {
    [self writeToFile];
  }
  return [NSData dataWithData:self.objectFile];
}

@end
