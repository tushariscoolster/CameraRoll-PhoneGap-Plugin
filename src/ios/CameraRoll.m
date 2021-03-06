#import "CameraRoll.h"
#import <Cordova/CDV.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation CameraRoll


-(void)count:(CDVInvokedUrlCommand*)command {
    
    //NSString *callbackId = [command.arguments pop];
    BOOL includePhotos   = [[command.arguments objectAtIndex:0] boolValue];
    BOOL includeVideos   = [[command.arguments objectAtIndex:1] boolValue];

    ALAssetsFilter *filter;
    if (includePhotos && includeVideos) {
        filter = [ALAssetsFilter allAssets];
    } else if (includePhotos) {
        filter = [ALAssetsFilter allPhotos];
    } else if (includeVideos) {
        filter = [ALAssetsFilter allVideos];
    } else {
        // nothing, so return error
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
        [self writeJavascript:[result toErrorCallbackString:command.callbackId]];
        return;
    }

    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    int __block numAssets = 0;
    [library enumerateGroupsWithTypes:ALAssetsGroupAll
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                               if (group) {
                                   [group setAssetsFilter:filter];
                                   numAssets += group.numberOfAssets;
                               }
                               CDVPluginResult* result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsInt:numAssets];
                               [self writeJavascript:[result toSuccessCallbackString:command.callbackId]];
                           }
     
                         failureBlock:^(NSError *err) {
                             CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
                             [self writeJavascript:[result toErrorCallbackString:command.callbackId]];
                         }];
}


-(void)find:(CDVInvokedUrlCommand*)command  {

    //NSString *callbackId = [command.arguments pop];
    NSInteger max        = [[command.arguments objectAtIndex:0] integerValue];
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupAll
                        usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                            if (group == nil) {
                                return;
                            }
                            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *innerStop) {
                                if (result == nil) {
                                    return;
                                }
                                NSURL *urld = (NSURL*) [[result defaultRepresentation]url];
                                NSData *imageData = [NSData dataWithContentsOfURL:urld];
                                NSString *base64EncodedImage = [imageData base64EncodedString];

                                [photos addObject:base64EncodedImage];
                                if (photos.count == max) {
                                    *innerStop = YES;
                                }
                            }];

                            if (photos.count > 0) {
                                CDVPluginResult* result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsArray:photos];
                                [self writeJavascript:[result toSuccessCallbackString:command.callbackId]];
                            } else {
                                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
                                [self writeJavascript:[result toErrorCallbackString:command.callbackId]];
                            }
                        } failureBlock:^(NSError *error) {
                            NSLog(@"%@", [error localizedDescription]);
                            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
                            [self writeJavascript:[result toErrorCallbackString:command.callbackId]];
                        }];
}

@end
