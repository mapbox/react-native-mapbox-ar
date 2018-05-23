//
//  BufferGeometry.m
//  RNLocateTest
//
//  Created by Dave Prukop on 4/27/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "BufferGeometry.h"

@interface FloatBuffer()

@property (nonatomic, strong) NSMutableArray<NSNumber *> *buffer;
@property (assign) NSUInteger offset;

- (instancetype)initWithCapacity:(NSUInteger)capacity;

@end

@implementation FloatBuffer

- (instancetype)init
{
  self = [super init];
  if (self) {
    NSLog(@"Use initWithCapacity");
  }
  return self;
}

- (instancetype)initWithCapacity:(NSUInteger)capacity
{
  self = [super init];
  if (self) {
    self.buffer = [[NSMutableArray alloc] initWithCapacity:capacity];
    self.offset = 0;
  }
  return self;
}

- (void)put:(id)value
{
  if ([value isKindOfClass:[NSNumber class]]) {
    [self.buffer setObject:value atIndexedSubscript:self.offset++];
  } else if ([value isKindOfClass:[Vector3 class]]) {
    [self put:[NSNumber numberWithFloat:[(Vector3 *)value x]]];
    [self put:[NSNumber numberWithFloat:[(Vector3 *)value y]]];
    [self put:[NSNumber numberWithFloat:[(Vector3 *)value z]]];
  } else if ([value isKindOfClass:[Vector2 class]]) {
    [self put:[NSNumber numberWithFloat:[(Vector2 *)value x]]];
    [self put:[NSNumber numberWithFloat:[(Vector2 *)value y]]];
  }
}

- (float)get:(NSUInteger)position
{
  return [[self.buffer objectAtIndex:position] floatValue];
}

- (NSUInteger)size
{
  return [self.buffer count];
}

@end



@interface IntBuffer()

@property (nonatomic, strong) NSMutableArray<NSNumber *> *buffer;
@property (assign) NSUInteger offset;

- (instancetype)initWithCapacity:(NSUInteger)capacity;

@end

@implementation IntBuffer

- (instancetype)init
{
  self = [super init];
  if (self) {
    NSLog(@"Use initWithCapacity");
  }
  return self;
}

- (instancetype)initWithCapacity:(NSUInteger)capacity
{
  self = [super init];
  if (self) {
    self.buffer = [[NSMutableArray alloc] initWithCapacity:capacity];
    self.offset = 0;
  }
  return self;
}

- (void)put:(float)value
{
  [self.buffer setObject:[NSNumber numberWithFloat:value] atIndexedSubscript:self.offset++];
}

- (int)get:(NSUInteger)position
{
  return [[self.buffer objectAtIndex:position] intValue];
}

- (NSUInteger)size
{
  return [self.buffer count];
}

@end



@implementation BufferGeometry

- (void)createBufferWithName:(NSString *)name andCapacity:(NSUInteger)capacity
{
  if ([name isEqualToString:@"index"]) {
    self.index = [[IntBuffer alloc] initWithCapacity:capacity];
  } else if ([name isEqualToString:@"position"]) {
    self.position = [[FloatBuffer alloc] initWithCapacity:capacity];
  } else if ([name isEqualToString:@"normal"]) {
    self.normal = [[FloatBuffer alloc] initWithCapacity:capacity];
  } else if ([name isEqualToString:@"uv"]) {
    self.uv = [[FloatBuffer alloc] initWithCapacity:capacity];
  }
}

@end
