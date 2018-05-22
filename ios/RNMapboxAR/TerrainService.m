//
//  TerrainService.m
//  RNLocateTest
//
//  Created by Dave Prukop on 5/1/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "TerrainService.h"
#import "MapboxManager.h"
#import "Object3D.h"
#import "PlaneGeometry.h"
#import "ObjFileExporter.h"
#import "TerrainTile.h"
#import "BitmapUtils.h"

static NSString *const RGB_URL = @"https://api.mapbox.com/v4/mapbox.terrain-rgb/%@/%@/%@.pngraw?access_token=%@";
static NSString *const SATELLITE_URL = @"https://api.mapbox.com/v4/mapbox.satellite/%@/%@/%@@2x.pngraw?access_token=%@";

@interface TerrainService()

@property (assign) int downloadTasksCompleted;
//@property (nonatomic, strong) NSData *rgbImageData;
@property (assign) int processingTasksCompleted;
@property (nonatomic, strong) NSMutableDictionary *assetURIs;

@property (assign) int width;
@property (assign) int height;
@property (assign) int sampleSize;
@property (assign) float zoom;
@property (assign) float heightModifier;
@property (nonatomic, strong) NSString *satelliteURI;
@property (nonatomic, strong) NSMutableArray<TerrainTile *> *tiles;
@property (nonatomic, strong) NSData *satelliteBitmapData;

@end

@implementation TerrainService

- (instancetype)initWithOptions:(NSDictionary *)options completion:(void (^)(NSDictionary *))callback
{
  self = [super init];
  if (self) {
    [self handleOptions:options];
    [self loadBitmapsForTilesWithCompletion:^{
      [self loadBitmapForSatelliteImageWithCompletion:^{
        [self processTerrainTilesWithCompletion:^(NSDictionary *localObjectURLs) {
          callback(localObjectURLs);
        }];
      }];
    }];
  }
  return self;
}

- (void)handleOptions:(NSDictionary *)options
{
  self.width = [[options objectForKey:@"width"] intValue];
  self.height = [[options objectForKey:@"height"] intValue];
  self.sampleSize = [[options objectForKey:@"sampleSize"] intValue];
  self.zoom = [[options objectForKey:@"zoom"] floatValue];
  self.heightModifier = [[options objectForKey:@"heightModifier"] floatValue];;
  
  self.satelliteURI = [options objectForKey:@"satelliteURI"];
  NSArray<NSDictionary *> *tilesDictionaries = [options objectForKey:@"tiles"];
  
  self.tiles = [[NSMutableArray alloc] initWithCapacity:[tilesDictionaries count]];
  for (int i=0; i<[tilesDictionaries count]; i++) {
    [self.tiles addObject:[[TerrainTile alloc] initWithDictionary:[tilesDictionaries objectAtIndex:i]]];
  }
}

- (void)loadBitmapsForTilesWithCompletion:(void (^)(void))callback {
  NSUInteger __block remainingTasks = [self.tiles count];
  for (int i=0; i<[self.tiles count]; i++) {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
      TerrainTile *tile = [self.tiles objectAtIndex:i];
      UIImage *image = [BitmapUtils getBitmapFromURL:[tile getFormattedURL] withOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.sampleSize] forKey:@"sampleSize"]];
      [tile setBitmap:image withSampleSize:self.sampleSize];
      if (--remainingTasks == 0) {
        callback();
      }
    });
  }
}

- (void)loadBitmapForSatelliteImageWithCompletion:(void (^)(void))callback {
  dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
    NSString *url = [self.satelliteURI stringByReplacingOccurrencesOfString:@"{ACCESS_TOKEN}" withString:[MapboxManager getInstance].accessToken];
    self.satelliteBitmapData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: url]];
    
    dispatch_sync(dispatch_get_main_queue(), ^(void) {
      callback();
    });
  });
}
  
- (void)processTerrainTilesWithCompletion:(void (^)(NSDictionary *))callback {
  CGFloat maxElevation = CGFLOAT_MIN;
  CGFloat minElevation = CGFLOAT_MAX;
  
  int tileWidth = self.width / self.sampleSize;
  int tileHeight = self.height / self.sampleSize;
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  unsigned char *rawData = (unsigned char*) calloc(tileHeight * tileWidth * 4, sizeof(unsigned char));
  NSUInteger bytesPerPixel = 4;
  NSUInteger bytesPerRow = bytesPerPixel * tileWidth;
  NSUInteger bitsPerComponent = 8;
  CGContextRef context = CGBitmapContextCreate(rawData, tileWidth, tileHeight,
                                               bitsPerComponent, bytesPerRow, colorSpace,
                                               kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
  CGColorSpaceRelease(colorSpace);
  
  for (int i=0; i<[self.tiles count]; i++) {
    TerrainTile *tile = [self.tiles objectAtIndex:i];
    CGImageRef imageRef = [tile.bitmap CGImage];
    CGFloat rectWidth = CGImageGetWidth(imageRef) / tile.sampleSize;
    CGFloat rectHeight = CGImageGetHeight(imageRef) / tile.sampleSize;
    CGFloat rectOffsetLeft = tile.px / tile.sampleSize;
    CGFloat rectOffsetTop = (tileHeight - (tile.py / tile.sampleSize)) - rectHeight;
    CGRect rect = CGRectMake(rectOffsetLeft, rectOffsetTop, rectWidth, rectHeight);
    CGContextDrawImage(context, rect, imageRef);
  }
  
  CGImageRef imgRef = CGBitmapContextCreateImage(context);
  UIImage* elevationImg = [UIImage imageWithCGImage:imgRef];
  
  CGContextRelease(context);
  
  NSUInteger numPixels = tileWidth * tileHeight;
  
  PlaneGeometry *geometry = [[PlaneGeometry alloc] initWithWidth:tileWidth andHeight:tileHeight andWidthSegments:tileWidth-1 andHeightSegments:tileHeight-1];
  
  NSMutableArray<NSNumber *> *elevation = [[NSMutableArray alloc] initWithCapacity:numPixels];
  
  NSUInteger byteIndex = 0;
  for (int i=0; i<numPixels; i++) {
    CGFloat R = (CGFloat) rawData[byteIndex];
    CGFloat G = (CGFloat) rawData[byteIndex + 1];
    CGFloat B = (CGFloat) rawData[byteIndex + 2];
    byteIndex += bytesPerPixel;
    
    CGFloat curElevation = ((R * 256 * 256 + G * 256 + B) / 10) - 10000;
    CGFloat elevationValue = [self scaleElevation:curElevation withZoomLevel:self.zoom andWithModifier:self.heightModifier / self.sampleSize];
    [elevation addObject:[[NSNumber alloc] initWithFloat:elevationValue]];
    
    if (curElevation < minElevation) {
      minElevation = curElevation;
    }
    
    if (curElevation > maxElevation) {
      maxElevation = curElevation;
    }
  }
  
  for (int i=0; i<[geometry.vertices count]; i++) {
    [geometry.vertices objectAtIndex:i].z = [[elevation objectAtIndex:i] floatValue];
  }
  
  Object3D *elevation3D = [[Object3D alloc] initWithName:@"terrain"];
  [geometry computeVertexNormals];
  [elevation3D addGeometry:geometry withName:@"elevation"];
  
  Object3D *wall3D = [[Object3D alloc] initWithName:@"sides"];
  PlaneGeometry *wallGeometry = [self createWallsWithGeometry:geometry andMinElevation:minElevation andMaxElevation:maxElevation andZoom:self.zoom andHeightModifier:self.heightModifier / self.sampleSize];
  [wall3D addGeometry:wallGeometry withName:@"wall"];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *terrainDirPath;
  terrainDirPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"terrain"];
  NSError *error;
  if (![[NSFileManager defaultManager] fileExistsAtPath:terrainDirPath])  //Does directory already exist?
  {
    if (![[NSFileManager defaultManager] createDirectoryAtPath:terrainDirPath
                                   withIntermediateDirectories:NO
                                                    attributes:nil
                                                         error:&error])
    {
      NSLog(@"Create directory error: %@", error);
    }
  }
  
  NSData *terrainObjFile = [ObjFileExporter createFileWithObject3D:elevation3D];
  NSString *terrainObjPath = [terrainDirPath stringByAppendingPathComponent:@"terrain.obj"];
  [fileManager createFileAtPath:terrainObjPath contents:terrainObjFile attributes:nil];
  
  NSData *wallObjFile = [ObjFileExporter createFileWithObject3D:wall3D];
  NSString *wallObjPath = [terrainDirPath stringByAppendingPathComponent:@"wall.obj"];
  [fileManager createFileAtPath:wallObjPath contents:wallObjFile attributes:nil];
  
  NSString *satellitePngPath = [terrainDirPath stringByAppendingPathComponent:@"satellite@2x.png"];
  [fileManager createFileAtPath:satellitePngPath contents:self.satelliteBitmapData attributes:nil];
  
  NSData *elevationImgData = UIImagePNGRepresentation(elevationImg);
  NSString *elevationPngPath = [terrainDirPath stringByAppendingPathComponent:@"elevation.png"];
  [fileManager createFileAtPath:elevationPngPath contents:elevationImgData attributes:nil];
  
  NSDictionary *objUris = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:terrainObjPath, wallObjPath, satellitePngPath, nil] forKeys:[NSArray arrayWithObjects:@"objFileURI", @"wallFileURI", @"satelliteFileURI", nil]];

  callback(objUris);
}

//- (instancetype)initWithX:(float)x andY:(float)y andZoom:(float)zoom completion:(void (^)(NSDictionary *localObjectURLs))callback
//{
//  self = [super init];
//  if (self) {
//    self.assetURIs = [[NSMutableDictionary alloc] init];
//    self.downloadTasksCompleted = 0;
//    [self getRGBTileWithX:x andY:y andZoom:zoom andAccessToken:[MapboxManager getInstance].accessToken completion:^(NSData *data) {
//      if (++self.downloadTasksCompleted == 1) {
//        [self processData:data andWithZoom:zoom andWithHeightModifier:1.0 withCompletion:callback];
//      }
//    }];
//  }
//  return self;
//}
//
//- (void)getRGBTileWithX:(float)x andY:(float)y andZoom:(float)zoom andAccessToken:(NSString *)accessToken completion:(void (^)(NSData *data))callback
//{
//  dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
//    NSString *URLString = [NSString stringWithFormat: RGB_URL, [NSString stringWithFormat:@"%0.0f", zoom], [NSString stringWithFormat:@"%0.0f", x], [NSString stringWithFormat:@"%0.0f", y], accessToken];
//    NSData *data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: URLString]];
//
//    dispatch_sync(dispatch_get_main_queue(), ^(void) {
//      callback(data);
//    });
//  });
//}
//
//- (void)processData:(NSData *)data andWithZoom:(float)zoom andWithHeightModifier:(float)heightModifier withCompletion:(void (^)(NSDictionary *localObjectURLs))callback
//{
//  self.processingTasksCompleted = 0;
//  [self processRGBImageData:data withZoom:zoom andWithHeightModifier:heightModifier withCompletion:^(NSDictionary *objURIs){
//    [self.assetURIs setObject:[objURIs objectForKey:@"objURI"] forKey:@"objFileURI"];
//    [self.assetURIs setObject:[objURIs objectForKey:@"wallURI"] forKey:@"wallFileURI"];
//    callback(self.assetURIs);
//  }];
//}
//
//- (void)processRGBImageData:(NSData *)data withZoom:(float)zoom andWithHeightModifier:(float)heightModifier withCompletion:(void (^)(NSDictionary *objURIs))callback
//{
//  dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
//    UIImage *image = [UIImage imageWithData:data];
//
//    CGImageRef imageRef = [image CGImage];
//    NSUInteger width = CGImageGetWidth(imageRef);
//    NSUInteger height = CGImageGetHeight(imageRef);
//    int tileWidth = (int) width / 4;
//    int tileHeight = (int) height / 4;
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    unsigned char *rawData = (unsigned char*) calloc(tileHeight * tileWidth * 4, sizeof(unsigned char));
//    NSUInteger bytesPerPixel = 4;
//    NSUInteger bytesPerRow = bytesPerPixel * tileWidth;
//    NSUInteger bitsPerComponent = 8;
//    CGContextRef context = CGBitmapContextCreate(rawData, tileWidth, tileHeight,
//                                                 bitsPerComponent, bytesPerRow, colorSpace,
//                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
//    CGColorSpaceRelease(colorSpace);
//    CGContextDrawImage(context, CGRectMake(0, 0, tileWidth, tileHeight), imageRef);
//    CGContextRelease(context);
//
//    NSUInteger numPixels = tileWidth * tileHeight;
//
//    PlaneGeometry *geometry = [[PlaneGeometry alloc] initWithWidth:tileWidth andHeight:tileHeight andWidthSegments:tileWidth-1 andHeightSegments:tileHeight-1];
//
//    CGFloat maxElevation = CGFLOAT_MIN;
//    CGFloat minElevation = CGFLOAT_MAX;
//    NSMutableArray<NSNumber *> *elevation = [[NSMutableArray alloc] initWithCapacity:numPixels];
//
//    NSUInteger byteIndex = 0;
//    for (int i=0; i<numPixels; i++) {
//      CGFloat R = (CGFloat) rawData[byteIndex];
//      CGFloat G = (CGFloat) rawData[byteIndex + 1];
//      CGFloat B = (CGFloat) rawData[byteIndex + 2];
//      byteIndex += bytesPerPixel;
//
//      CGFloat curElevation = ((R * 256 * 256 + G * 256 + B) / 10) - 10000;
//      CGFloat elevationValue = [self scaleElevation:curElevation withZoomLevel:8 andWithModifier:heightModifier];
//      [elevation addObject:[[NSNumber alloc] initWithFloat:elevationValue]];
//
//      if (curElevation < minElevation) {
//        minElevation = curElevation;
//      }
//
//      if (curElevation > maxElevation) {
//        maxElevation = curElevation;
//      }
//    }
//
//    for (int i=0; i<[geometry.vertices count]; i++) {
//      [geometry.vertices objectAtIndex:i].z = [[elevation objectAtIndex:i] floatValue];
//    }
//
//    Object3D *elevation3D = [[Object3D alloc] initWithName:@"terrain"];
//    [geometry computeVertexNormals];
//    [elevation3D addGeometry:geometry withName:@"elevation"];
//
//    Object3D *wall3D = [[Object3D alloc] initWithName:@"sides"];
//    PlaneGeometry *wallGeometry = [self createWallsWithGeometry:geometry andMinElevation:minElevation andMaxElevation:maxElevation andZoom:zoom andHeightModifier:heightModifier];
//    [wall3D addGeometry:wallGeometry withName:@"wall"];
//
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *terrainDirPath;
//    terrainDirPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"terrain"];
//    NSError *error;
//    if (![[NSFileManager defaultManager] fileExistsAtPath:terrainDirPath])  //Does directory already exist?
//    {
//      if (![[NSFileManager defaultManager] createDirectoryAtPath:terrainDirPath
//                                     withIntermediateDirectories:NO
//                                                      attributes:nil
//                                                           error:&error])
//      {
//        NSLog(@"Create directory error: %@", error);
//      }
//    }
//
//    NSData *terrainObjFile = [ObjFileExporter createFileWithObject3D:elevation3D];
//    NSString *terrainObjPath = [terrainDirPath stringByAppendingPathComponent:@"terrain.obj"];
//    [fileManager createFileAtPath:terrainObjPath contents:terrainObjFile attributes:nil];
//
//    NSData *wallObjFile = [ObjFileExporter createFileWithObject3D:wall3D];
//    NSString *wallObjPath = [terrainDirPath stringByAppendingPathComponent:@"wall.obj"];
//    [fileManager createFileAtPath:wallObjPath contents:wallObjFile attributes:nil];
//
//    NSDictionary *objUris = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:terrainObjPath, wallObjPath, nil] forKeys:[NSArray arrayWithObjects:@"objURI", @"wallURI", nil]];
//
//    dispatch_sync(dispatch_get_main_queue(), ^(void) {
//      callback(objUris);
//    });
//  });
//}

- (CGFloat)scaleElevation:(CGFloat)elevation withZoomLevel:(CGFloat)zoomLevel andWithModifier:(float)modifier {
  CGFloat M_TO_PX_SCALAR = 40075000.0;
  float value = elevation / fabs(M_TO_PX_SCALAR * cos(M_PI / 180) / (pow(2.0, zoomLevel) * 256));
  return value * modifier;
}

- (PlaneGeometry *)createWallsWithGeometry:(PlaneGeometry *)geometry andMinElevation:(CGFloat)minElevation andMaxElevation:(CGFloat)maxElevation andZoom:(float)zoom andHeightModifier:(float)heightModifier
{
  NSMutableArray<NSNumber *> *indices = [[NSMutableArray alloc] init];
  
  // north
  for (int i=0; i<geometry.width - 1; i++) {
    [indices addObject:[NSNumber numberWithInt:i]];
  }
  
  // east
  for (int i=1; i<geometry.height; i++) {
    [indices addObject:[NSNumber numberWithInt:i * geometry.width - 1]];
  }
  
  // south
  for (int i=0; i<geometry.width - 1; i++) {
    [indices addObject:[NSNumber numberWithInt:geometry.height * geometry.width - i - 1]];
  }
  
  // west
  for (int i=1; i<geometry.height; i++) {
    [indices addObject:[NSNumber numberWithInt:geometry.height * geometry.width - i * geometry.width]];
  }
  
  [indices addObject:[NSNumber numberWithInt:0]];
  indices = [[[indices reverseObjectEnumerator] allObjects] mutableCopy];
  
  int wallLength = (int)[indices count];
  PlaneGeometry *wallGeometry = [[PlaneGeometry alloc] initWithWidth:wallLength andHeight:2 andWidthSegments:wallLength - 1 andHeightSegments:1];
  float wallBottom = minElevation - (maxElevation - minElevation) / 10.0f;
  float scaledWallBottom = [self scaleElevation:wallBottom withZoomLevel:zoom andWithModifier:heightModifier];
  
  for (int i=0; i<[indices count]; i++) {
    int index = [[indices objectAtIndex:i] intValue];
    Vector3 *vertex = [geometry.vertices objectAtIndex:index];
    
    [wallGeometry.vertices objectAtIndex:i].x = vertex.x;
    [wallGeometry.vertices objectAtIndex:i + wallLength].x = vertex.x;
    
    [wallGeometry.vertices objectAtIndex:i].y = vertex.y;
    [wallGeometry.vertices objectAtIndex:i + wallLength].y = vertex.y;
    
    [wallGeometry.vertices objectAtIndex:i].z = vertex.z;
    [wallGeometry.vertices objectAtIndex:i + wallLength].z = scaledWallBottom;
  }
  
  return wallGeometry;
}

@end
