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
    NSArray* songList = [self getMusic];
    
    if (command.callbackId) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:songList];
        [result setKeepCallbackAsBool:NO];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (NSArray*)getMusic
{
    
    
    NSMutableArray *songList = [[NSMutableArray alloc] init];
    
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    
    NSArray *itemsFromGenericQuery = [everything items];
    
    
    
    for (MPMediaItem *song in itemsFromGenericQuery){
        
        
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
        
        
        //store image in device
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        
        //UIImage * imageToSave = [UIImage imageNamed:@"Icon.png"];
        NSData * binaryImageData = UIImagePNGRepresentation(artworkImage);
        
        int randomInt = rand() % 74;
        NSString* str = @"VP_IMG_";
        NSString* ext = @".png";
        NSString* imageName = [str stringByAppendingString:[NSString stringWithFormat:@"%d",randomInt]];
        [binaryImageData writeToFile:[basePath stringByAppendingPathComponent:[imageName stringByAppendingString:ext]] atomically:YES];
        
        NSNumber *duration = [song valueForProperty:MPMediaItemPropertyPlaybackDuration];
        NSString *genre = [song valueForProperty:MPMediaItemPropertyGenre];
        
    
        AVURLAsset *songURL = [AVURLAsset URLAssetWithURL:songurl options:nil];
        
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentDir = [path objectAtIndex:0];
    
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:songURL presetName:AVAssetExportPresetAppleM4A];
        
        exporter.outputFileType = @"com.apple.m4a-audio";
        
        NSString *filename = [NSString stringWithFormat:@"%@.m4a",title];
        
        NSString *outputfile = [documentDir stringByAppendingPathComponent:filename];
        
        NSURL *exportURL = [NSURL fileURLWithPath:outputfile];
        
        exporter.outputURL  = exportURL;
        
        NSURL *audioURL = exportURL;
        
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        
        
        [songInfo setObject:[NSString stringWithFormat:@"%d",randomInt] forKey:@"Id"];
        
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
        
        //[songInfo setObject:[songurl absoluteString] forKey:@"Path"]; directorio de ipod-library
        [songInfo setObject:[audioURL absoluteString] forKey:@"Path"];
        if (artImageFound) {
            NSString* slash = @"/";
            [songInfo setObject:[basePath stringByAppendingString:[slash stringByAppendingString:[imageName stringByAppendingString:ext]]] forKey:@"Cover"];
            //[songInfo setObject:[imgData base64EncodedStringWithOptions:0] forKey:@"Cover"];
        } else {
            [songInfo setObject:@"No Image" forKey:@"Cover"];
        }
        
        [songInfo setObject:duration forKey:@"Duration"];
        
        if (genre != nil){
            [songInfo setObject:genre forKey:@"Genre"];
        } else {
            [songInfo setObject:@"No Genre" forKey:@"Genre"];
        }
        
        //[songInfo setObject:[audioURL absoluteString] forKey:@"exportedurl"];
        //[songInfo setObject:filename forKey:@"filename"];
        
        
        [songList addObject:songInfo];
        
    }
    
    return songList;
}

@end