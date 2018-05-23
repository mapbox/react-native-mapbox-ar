//
//  BufferGeometry.h
//  RNLocateTest
//
//  Created by Dave Prukop on 4/27/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector2.h"
#import "Vector3.h"

@interface FloatBuffer : NSObject

- (void)put:(id)value;
- (float)get:(NSUInteger)position;
- (NSUInteger)size;

@end



@interface IntBuffer : NSObject

- (void)put:(float)value;
- (int)get:(NSUInteger)position;
- (NSUInteger)size;

@end



@interface BufferGeometry : NSObject

@property (nonatomic, strong) IntBuffer *index;

@property (nonatomic, strong) FloatBuffer *position;
@property (nonatomic, strong) FloatBuffer *normal;
@property (nonatomic, strong) FloatBuffer *uv;

- (void)createBufferWithName:(NSString *)name andCapacity:(NSUInteger)capacity;

@end
