//
//  RemoteController.h
//  Remote
//
//  Created by Alex on 06/05/2009.
//  Copyright 2009 Alex Price.
//

#import <Cocoa/Cocoa.h>
#import "HIDRemote.h"

@interface RemoteController : NSObject <HIDRemoteDelegate>
{
}

+(void)playVolumeSound;
+ (BOOL)startRemoteControl;
+(void)volumeUp;
+(void)volumeDown;
+ (void)hidRemote:(HIDRemote *)hidRemote eventWithButton:(HIDRemoteButtonCode)buttonCode isPressed:(BOOL)isPressed fromHardwareWithAttributes:(NSMutableDictionary *)attributes;

@end
