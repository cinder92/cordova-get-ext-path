/********* getExtPath.m Cordova Plugin Implementation *******/

#import "getExtPath.h"
#import <Cordova/CDV.h>
#import <objc/message.h>
#import <MediaPlayer/MPMediaQuery.h>
#import <MediaPlayer/MPMediaPlaylist.h>
#import <AVFoundation/AVFoundation.h>

@implementation getExtPath


- (void)coolMethod:(CDVInvokedUrlCommand*)command
{
 
    __block CDVPluginResult *plresult = nil;
    NSMutableArray *songList;
    __block int completed = 0;
    //songsList = [[NSMutableArray alloc] init];
    
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    
    NSArray *itemsFromGenericQuery = [everything items];
    
    NSUInteger selcount = [itemsFromGenericQuery count];

    
    for (MPMediaItem *song in itemsFromGenericQuery){
        //NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
        
        
        BOOL artImageFound = NO;
        NSData *imgData;
        NSString *title = [song valueForProperty:MPMediaItemPropertyTitle];
        NSString *albumTitle = [song valueForProperty:MPMediaItemPropertyAlbumTitle];
        NSString *artist = [song valueForProperty:MPMediaItemPropertyArtist];
        NSURL *songurl = [song valueForProperty:MPMediaItemPropertyAssetURL];
        MPMediaItemArtwork *artImage = [song valueForProperty:MPMediaItemPropertyArtwork];
        UIImage *artworkImage = [artImage imageWithSize:CGSizeMake(artImage.bounds.size.width, artImage.bounds.size.height)];
        if(artworkImage != nil){
            imgData = UIImagePNGRepresentation(artworkImage);
            artImageFound = YES;
        }
        
        NSNumber *duration = [song valueForProperty:MPMediaItemPropertyPlaybackDuration];
        NSString *genre = [song valueForProperty:MPMediaItemPropertyGenre];
        
        /*NSLog(@"title = %@",title);
        NSLog(@"albumTitle = %@",albumTitle);
        NSLog(@"artist = %@",artist);
        NSLog(@"songurl = %@",songurl);*/
        
        AVURLAsset *songURL = [AVURLAsset URLAssetWithURL:songurl options:nil];
        
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentDir = [path objectAtIndex:0];
        
        //NSLog(@"Compatible Preset for selected Song = %@", [AVAssetExportSession exportPresetsCompatibleWithAsset:songURL]);
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:songURL presetName:AVAssetExportPresetAppleM4A];
        
        exporter.outputFileType = @"com.apple.m4a-audio";
        
        NSString *filename = [NSString stringWithFormat:@"%@.m4a",title];
        
        NSString *outputfile = [documentDir stringByAppendingPathComponent:filename];
        
        NSURL *exportURL = [NSURL fileURLWithPath:outputfile];
        
        exporter.outputURL  = exportURL;
        
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            int exportStatus = exporter.status;
            completed++;
            switch (exportStatus) {
                case AVAssetExportSessionStatusFailed:{
                    NSError *exportError = exporter.error;
                    NSLog(@"AVAssetExportSessionStatusFailed = %@",exportError);
                    NSString *errmsg = [exportError description];
                    plresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errmsg];
                    break;
                }
                case AVAssetExportSessionStatusCompleted:{
                    
                    NSURL *audioURL = exportURL;
                    NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
                        

                    /*

                    items.put("Id", thisId);
                    items.put("Album", album);
                    items.put("Author", author);
                    items.put("Title", title);
                    items.put("Genre", genero);
                    items.put("Cover", encoded);
                    items.put("Blur", blurred);
                    items.put("Duration", Duration);
                    items.put("Path", thisPath);*/

                    NSLog(@"AVAssetExportSessionStatusCompleted %@",audioURL);
                    if(title != nil) {
                        [songInfo setObject:title forKey:@"Title"];
                    } else {
                        [songInfo setObject:@"No Title" forKey:@"Title"];
                    }
                    if(albumTitle != nil) {
                        [songInfo setObject:albumTitle forKey:@"Album"];
                    } else {
                        [songInfo setObject:@"No Album" forKey:@"Album"];
                    }
                    if(artist !=nil) {
                        [songInfo setObject:artist forKey:@"Author"];
                    } else {
                        [songInfo setObject:@"No Artist" forKey:@"Author"];
                    }
                    
                    [songInfo setObject:[songurl absoluteString] forKey:@"Path"];
                    if (artImageFound) {
                        [songInfo setObject:[imgData base64EncodedStringWithOptions:0] forKey:@"Cover"];
                    } else {
                        [songInfo setObject:@"No Image" forKey:@"Cover"];
                    }
                    
                    [songInfo setObject:duration forKey:@"Duration"];
                    if (genre != nil){
                        [songInfo setObject:genre forKey:@"Genre"];
                    } else {
                        [songInfo setObject:@"No Genre" forKey:@"Genre"];
                    }
                    
                    [songInfo setObject:[audioURL absoluteString] forKey:@"exportedurl"];
                    [songInfo setObject:filename forKey:@"filename"];
                    
                    [songList addObject:songInfo];
                    
                    //NSLog(@"Audio Data = %@",songsList);
                    NSLog(@"Export Completed = %d out of Total Selected = %lu",completed,(unsigned long)selcount);
                    if (completed == selcount) {
                        plresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:songList];
                        [self.commandDelegate sendPluginResult:plresult callbackId:command.callbackId];
                    }
                    break;
                }
                case AVAssetExportSessionStatusCancelled:{
                    NSLog(@"AVAssetExportSessionStatusCancelled");
                    plresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cancelled"];
                    break;
                }
                case AVAssetExportSessionStatusUnknown:{
                    NSLog(@"AVAssetExportSessionStatusCancelled");
                    plresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unknown"];
                    break;
                }
                case AVAssetExportSessionStatusWaiting:{
                    NSLog(@"AVAssetExportSessionStatusWaiting");
                    plresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Waiting"];
                    break;
                }
                case AVAssetExportSessionStatusExporting:{
                    NSLog(@"AVAssetExportSessionStatusExporting");
                    plresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Exporting"];
                    break;
                }
                    
                default:{
                    NSLog(@"Didnt get any status");
                    break;
                }
            }
        }];
        
        
        //NSLog (@"%@", songTitle);
        //NSLog (@"t%@", [song valueForProperty: MPMediaItemPropertyPersistentID]);
    }
}

@end