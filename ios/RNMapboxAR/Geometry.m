//
//  Geometry.m
//  RNLocateTest
//
//  Created by Dave Prukop on 4/26/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "Geometry.h"

@implementation Geometry

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.faces = [[NSArray alloc] init];
    self.faceVertexUvs = [[NSArray alloc] init];
  }
  return self;
}

- (void)computeVertexNormals
{
  NSMutableArray<Vector3 *> *localVertices = [[NSMutableArray alloc] initWithCapacity:[self.vertices count]];
  
  for (int i=0; i<[self.vertices count]; i++) {
    [localVertices addObject:[[Vector3 alloc] init]];
  }
  
  Vector3 *vA;
  Vector3 *vB;
  Vector3 *vC;
  
  Vector3 *localA;
  Vector3 *localB;
  Vector3 *localC;
  
  Vector3 *cb = [[Vector3 alloc] init];
  Vector3 *ab = [[Vector3 alloc] init];
  
  for (int i=0; i<[self.faces count]; i++) {
    Face3 *face = [self.faces objectAtIndex:i];
    
    vA = [self.vertices objectAtIndex:face.a];
    vB = [self.vertices objectAtIndex:face.b];
    vC = [self.vertices objectAtIndex:face.c];
    
    [cb subVectorWithA:vC andB:vB];
    [ab subVectorWithA:vA andB:vB];
    [cb cross:ab];
    
    [[localVertices objectAtIndex:face.a] add:cb];
    [[localVertices objectAtIndex:face.b] add:cb];
    [[localVertices objectAtIndex:face.c] add:cb];
    
    localA = [localVertices objectAtIndex:face.a];
    [localA normalize];
    
    localB = [localVertices objectAtIndex:face.b];
    [localB normalize];
    
    localC = [localVertices objectAtIndex:face.c];
    [localC normalize];
    
    [[face.vertexNormals objectAtIndex:0] copy:localA];
    [[face.vertexNormals objectAtIndex:1] copy:localB];
    [[face.vertexNormals objectAtIndex:2] copy:localC];
  }
}

- (void)computeFaceNormals
{
  Vector3 *cb = [[Vector3 alloc] init];
  Vector3 *ab = [[Vector3 alloc] init];
  
  for (int i=0; i<[self.faces count]; i++) {
    Face3 *face = [self.faces objectAtIndex:i];
    
    Vector3 *vA = [self.vertices objectAtIndex:face.a];
    Vector3 *vB = [self.vertices objectAtIndex:face.b];
    Vector3 *vC = [self.vertices objectAtIndex:face.c];
    
    [cb subVectorWithA:vC andB:vB];
    [ab subVectorWithA:vA andB:vB];
    [cb cross:ab];
    [cb normalize];
    [face.normal copy:cb];
  }
}

- (void)addFaceWithA:(int)a andB:(int)b andC:(int)c andVertexNormals:(NSArray<Vector3 *> *)vertexNormals andFaceVertexUvs:(NSArray<Vector2 *> *)faceVertexUvs
{
  Face3 *face = [[Face3 alloc] initWithA:a andB:b andC:c andVertexNormals:vertexNormals];
  NSMutableArray *localFaces = [NSMutableArray arrayWithArray:self.faces];
  [localFaces addObject:face];
  self.faces = [NSArray arrayWithArray:localFaces];
  
  if (self.faceVertexUvs != nil) {
    NSMutableArray *localFaceVertexUvs = [NSMutableArray arrayWithArray:self.faceVertexUvs];
    [localFaceVertexUvs addObject:faceVertexUvs];
    self.faceVertexUvs = [NSArray arrayWithArray:localFaceVertexUvs];
  }
}

- (BufferGeometry *)toBufferGeometry
{
  BufferGeometry *bufferGeometry = [[BufferGeometry alloc] init];
  
  [bufferGeometry createBufferWithName:@"position" andCapacity:[self.faces count] * 9];
  [bufferGeometry createBufferWithName:@"normal" andCapacity:[self.faces count] * 9];
  [bufferGeometry createBufferWithName:@"uv" andCapacity:[self.faces count] * 6];
  
  for (int i=0; i<[self.faces count]; i++) {
    Face3 *face = [self.faces objectAtIndex:i];
    
    Vector3 *vA = [self.vertices objectAtIndex:face.a];
    [bufferGeometry.position put:vA];
    
    Vector3 *vB = [self.vertices objectAtIndex:face.b];
    [bufferGeometry.position put:vB];
    
    Vector3 *vC = [self.vertices objectAtIndex:face.c];
    [bufferGeometry.position put:vC];
    
    Vector3 *vN = [face.vertexNormals objectAtIndex:0];
    [bufferGeometry.normal put:vN];
    
    vN = [face.vertexNormals objectAtIndex:1];
    [bufferGeometry.normal put:vN];
    
    vN = [face.vertexNormals objectAtIndex:2];
    [bufferGeometry.normal put:vN];
    
    NSArray<Vector2 *> *vertexUvs = [self.faceVertexUvs objectAtIndex:i];
    for (int i=0; i<[vertexUvs count]; i++) {
      Vector2 *vertexUv = [vertexUvs objectAtIndex:i];
      [bufferGeometry.uv put:vertexUv];
    }
  }
  
  return bufferGeometry;
}

- (void)fromBufferGeometry:(BufferGeometry *)bufferGeometry
{
  IntBuffer *indices = bufferGeometry.index;
  FloatBuffer *positions = bufferGeometry.position;
  FloatBuffer *normals = bufferGeometry.normal;
  FloatBuffer *uvs = bufferGeometry.uv;
  
  int i = 0;
  int j = 0;
  
  NSMutableArray<Vector3 *> *tempNormals = [NSMutableArray arrayWithCapacity:[normals size] / 3];
  NSMutableArray<Vector2 *> *tempUvs = [NSMutableArray arrayWithCapacity:[uvs size] / 2];
  NSMutableArray<Vector3 *> *localVertices = [NSMutableArray arrayWithCapacity:[positions size] / 3];
  
  int vOffset = 0;
  int nOffset = 0;
  int uOffset = 0;
  
  while (i < [positions size]) {
    [localVertices setObject:[[Vector3 alloc] initWithX:[positions get:i] andY:[positions get:i+1] andZ:[positions get:i+2]] atIndexedSubscript:vOffset++];
    
    if ([normals size] > 0) {
      [tempNormals setObject:[[Vector3 alloc] initWithX:[normals get:i] andY:[normals get:i+1] andZ:[normals get:i+2]] atIndexedSubscript:nOffset++];
    }
    
    if ([uvs size] > 0) {
      [tempUvs setObject:[[Vector2 alloc] initWithX:[uvs get:j] andY:[uvs get:j+1]] atIndexedSubscript:uOffset++];
    }
    
    i += 3;
    j += 2;
  }
  
  self.vertices = [NSArray arrayWithArray:localVertices];
  
  for (int f=0; f<[indices size]; f+=3) {
    int a = [indices get:f];
    int b = [indices get:f+1];
    int c = [indices get:f+2];
    
    NSMutableArray<Vector3 *> *vertexNormals = nil;
    if ([normals size] > 0) {
      vertexNormals = [[NSMutableArray alloc] initWithCapacity:3];
      [vertexNormals setObject:[[tempNormals objectAtIndex:a] clone] atIndexedSubscript:0];
      [vertexNormals setObject:[[tempNormals objectAtIndex:b] clone] atIndexedSubscript:1];
      [vertexNormals setObject:[[tempNormals objectAtIndex:c] clone] atIndexedSubscript:2];
    }
    
    NSMutableArray<Vector2 *> *localFaceVertexUvs = nil;
    if ([uvs size] > 0) {
      localFaceVertexUvs = [[NSMutableArray alloc] initWithCapacity:3];
      [localFaceVertexUvs setObject:[[tempUvs objectAtIndex:a] clone] atIndexedSubscript:0];
      [localFaceVertexUvs setObject:[[tempUvs objectAtIndex:b] clone] atIndexedSubscript:1];
      [localFaceVertexUvs setObject:[[tempUvs objectAtIndex:c] clone] atIndexedSubscript:2];
    }
    
    [self addFaceWithA:a andB:b andC:c andVertexNormals:vertexNormals andFaceVertexUvs:localFaceVertexUvs];
  }
  
  [self computeFaceNormals];
}

@end
