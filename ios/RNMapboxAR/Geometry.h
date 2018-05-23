//
//  Geometry.h
//  RNLocateTest
//
//  Created by Dave Prukop on 4/26/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BufferGeometry.h"
#import "Face3.h"
#import "Vector2.h"
#import "Vector3.h"

@interface Geometry : NSObject

@property (nonatomic, strong) NSArray<Vector3 *> *vertices;
@property (nonatomic, strong) NSArray<Face3 *> *faces;
@property (nonatomic, strong) NSArray<NSArray<Vector2 *>*> *faceVertexUvs;

- (void)computeVertexNormals;
- (void)computeFaceNormals;
- (void)addFaceWithA:(int)a andB:(int)b andC:(int)c andVertexNormals:(NSArray<Vector3 *> *)vertexNormals andFaceVertexUvs:(NSArray<Vector2 *> *)faceVertexUvs;
- (BufferGeometry *)toBufferGeometry;
- (void)fromBufferGeometry:(BufferGeometry *)bufferGeometry;

@end
