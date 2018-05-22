//
//  Face3.h
//  RNLocateTest
//
//  Created by Dave Prukop on 4/26/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector3.h"

@interface Face3 : NSObject

@property (assign) int a;
@property (assign) int b;
@property (assign) int c;

@property (nonatomic, strong) Vector3 *normal;
@property (nonatomic, strong) NSArray<Vector3 *> *vertexNormals;

- (instancetype)initWithA:(int)a andB:(int)b andC:(int)c andVertexNormals:(NSArray<Vector3 *> *)vertexNormals;

@end
