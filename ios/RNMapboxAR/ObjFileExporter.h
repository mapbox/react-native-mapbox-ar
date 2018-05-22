//
//  ObjFileExporter.h
//  RNLocateTest
//
//  Created by Dave Prukop on 5/2/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Object3D.h"

@interface ObjFileExporter : NSObject

+ (NSData *)createFileWithObject3D:(Object3D *)object3D;

@end
