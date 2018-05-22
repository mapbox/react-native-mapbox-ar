//
//  Object3D.h
//  RNLocateTest
//
//  Created by Dave Prukop on 4/27/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Geometry.h"

@interface Object3D : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDictionary *geometries;

- (instancetype)initWithName:(NSString *)name;
- (void)addGeometry:(Geometry *)geometry withName:(NSString *)name;

@end
