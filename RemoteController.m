//
//  RemoteController.m
//  Remote
//
//  Created by Alex on 06/05/2009.
//  Copyright 2009 Alex Price.
//

#import "RemoteController.h"
#import <CoreAudio/CoreAudio.h>

@implementation RemoteController

+ (void)load
{
	[RemoteController startRemoteControl];
}

+ (BOOL)startRemoteControl
{
	HIDRemoteMode remoteMode;
	HIDRemote *hidRemote;
	
	hidRemote = [HIDRemote sharedHIDRemote];
	remoteMode = kHIDRemoteModeExclusive;
	
	// Check whether the installation of Candelair is required to reliably operate in this mode
	if ([HIDRemote isCandelairInstallationRequiredForRemoteMode:remoteMode])
	{
		// Reliable usage of the remote in this mode under this operating system version
		// requires the Candelair driver to be installed. Let's inform the user about it.
		NSAlert *alert;
		
		if ((alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Candelair driver installation necessary", @"")
									 defaultButton:NSLocalizedString(@"Download", @"")
								   alternateButton:NSLocalizedString(@"More information", @"")
									   otherButton:NSLocalizedString(@"Cancel", @"")
						 informativeTextWithFormat:NSLocalizedString(@"An additional driver needs to be installed before %@ can reliably access the remote under the OS version installed on your computer.", @""), [[NSBundle mainBundle] objectForInfoDictionaryKey:(id)kCFBundleNameKey]]) != nil)
		{
			switch ([alert runModal])
			{
				case NSAlertDefaultReturn:
					[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.candelair.com/download/"]];
					break;
					
				case NSAlertAlternateReturn:
					[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.candelair.com/"]];
					break;
			}
		}
	}	
	else
	{
		[[HIDRemote sharedHIDRemote] setUnusedButtonCodes:[NSArray arrayWithObjects:
														   /*[NSNumber numberWithInt:(int)kHIDRemoteButtonCodeMenuHold],*/
														   [NSNumber numberWithInt:(int)kHIDRemoteButtonCodePlayHold],
														   [NSNumber numberWithInt:(int)kHIDRemoteButtonCodeRightHold],
														   [NSNumber numberWithInt:(int)kHIDRemoteButtonCodeLeftHold],
														   [NSNumber numberWithInt:(int)kHIDRemoteButtonCodeCenterHold],
														   nil]
		 ];
		[hidRemote setExclusiveLockLendingEnabled:YES];
		
		// Start remote control
		if ([hidRemote startRemoteControl:remoteMode])
		{
			// Start was successful
			NSLog(@"HIDRemote started successfully");
			[[HIDRemote sharedHIDRemote] setDelegate:self];
			return (YES);
		}
		else
		{
			// Start failed
			NSLog(@"Couldn't start HIDRemote");
		}
	}
	
	return (NO);
}


- (BOOL)hidRemote:(HIDRemote *)hidRemote lendExclusiveLockToApplicationWithInfo:(NSDictionary *)applicationInfo
{
	NSNumber *remoteModeNumber;
	
	if ((remoteModeNumber = [applicationInfo objectForKey:kHIDRemoteDNStatusModeKey]) != nil)
	{
		switch ((HIDRemoteMode)[remoteModeNumber intValue])
		{
				// Lend exclusive lock to all applications operating in shared or
				// exclusive-auto mode
			case kHIDRemoteModeShared:
			case kHIDRemoteModeExclusiveAuto:
				return (YES);
				break;
			default:
				break;
		}
	}
	
	// Don't lend the lock to applications operating in other modes
	return (NO);
}

- (void)hidRemote:(HIDRemote *)hidRemote eventWithButton:(HIDRemoteButtonCode)buttonCode isPressed:(BOOL)isPressed fromHardwareWithAttributes:(NSMutableDictionary *)attributes
{
	[RemoteController hidRemote:hidRemote eventWithButton:buttonCode isPressed:isPressed fromHardwareWithAttributes:attributes];
}

+ (void)hidRemote:(HIDRemote *)hidRemote eventWithButton:(HIDRemoteButtonCode)buttonCode isPressed:(BOOL)isPressed fromHardwareWithAttributes:(NSMutableDictionary *)attributes
{
	NSAppleScript *script;
	NSLog(@"Remote button pressed");
	if(!isPressed){
		switch (buttonCode)
		{
            case kHIDRemoteButtonCodeUp:
                [RemoteController volumeUp];
                script = [[NSAppleScript alloc] initWithSource:
                          @"tell application \"Spotify\"\n\
                          if sound volume > 95 then\n\
                          set the sound volume to 100\n\
                          else\n\
                          set the sound volume to sound volume + 5\n\
                          end if\n\
                          end tell\n\
                          "];
                [script performSelectorOnMainThread:@selector(executeAndReturnError:) withObject:nil waitUntilDone:YES];
                [script release];
                break;
                
            case kHIDRemoteButtonCodeUpHold:
                script = [[NSAppleScript alloc] initWithSource:
                          @"tell application \"Spotify\"\n\
                          set the sound volume to 80\n\
                          end tell\n\
                          "];
                [script performSelectorOnMainThread:@selector(executeAndReturnError:) withObject:nil waitUntilDone:YES];
                [script release];
                break;
                
            case kHIDRemoteButtonCodeDown:
                script = [[NSAppleScript alloc] initWithSource:
                          @"tell application \"Spotify\"\n\
                          if sound volume < 5 then\n\
                          set the sound volume to 0\n\
                          else\n\
                          set the sound volume to sound volume - 5\n\
                          end if\n\
                          end tell\n\
                          "];
                [script performSelectorOnMainThread:@selector(executeAndReturnError:) withObject:nil waitUntilDone:YES];
                [script release];
                break;
                
            case kHIDRemoteButtonCodeDownHold:
                script = [[NSAppleScript alloc] initWithSource:
                          @"tell application \"Spotify\"\n\
                          set the sound volume to 20\n\
                          end tell\n\
                          "];
                [script performSelectorOnMainThread:@selector(executeAndReturnError:) withObject:nil waitUntilDone:YES];
                [script release];
                break;
				
			case kHIDRemoteButtonCodeLeft:
				script = [[NSAppleScript alloc] initWithSource:@"tell application \"Spotify\" to previous track"];
				[script performSelectorOnMainThread:@selector(executeAndReturnError:) withObject:nil waitUntilDone:YES];
				[script release];
				break;
				
			case kHIDRemoteButtonCodeLeftHold:
				break;
				
			case kHIDRemoteButtonCodeRight:
				script = [[NSAppleScript alloc] initWithSource:@"tell application \"Spotify\" to next track"];
				[script performSelectorOnMainThread:@selector(executeAndReturnError:) withObject:nil waitUntilDone:YES];
				[script release];
				break;
				
			case kHIDRemoteButtonCodeRightHold:
				break;
				
			case kHIDRemoteButtonCodeCenter:
				script = [[NSAppleScript alloc] initWithSource:@"tell application \"Spotify\" to playpause"];
				[script performSelectorOnMainThread:@selector(executeAndReturnError:) withObject:nil waitUntilDone:YES];
				[script release];
				break;
				
			case kHIDRemoteButtonCodeCenterHold:
				break;
				
			case kHIDRemoteButtonCodeMenu:
				break;
				
			case kHIDRemoteButtonCodeMenuHold:
				script = [[NSAppleScript alloc] initWithSource:@"tell application \"Spotify\" to quit"];
				[script performSelectorOnMainThread:@selector(executeAndReturnError:) withObject:nil waitUntilDone:YES];
				[script release];
				break;
				
			case kHIDRemoteButtonCodePlay:
				script = [[NSAppleScript alloc] initWithSource:@"tell application \"Spotify\" to playpause"];
				[script performSelectorOnMainThread:@selector(executeAndReturnError:) withObject:nil waitUntilDone:YES];
				[script release];
				break;
				
			case kHIDRemoteButtonCodePlayHold:
				break;
				
			default:
				break;
		}	
	}
}

+(void)playVolumeSound
{
	NSSound *vol = [[NSSound alloc] initWithContentsOfFile:@"/System/Library/LoginPlugins/BezelServices.loginPlugin/Contents/Resources/volume.aiff" byReference:YES];
	[vol play];
	[vol autorelease];
}

+(void)volumeUp
{
	NSAppleScript *as = [[NSAppleScript alloc] initWithSource:@"\nset curVolume to output volume of (get volume settings)\nif curVolume < 90 then\nset newVolume to curVolume + 10\nelse\nset newVolume to 100\nend if\nset volume output volume newVolume\nset volume output muted false\n"];
	[as performSelectorOnMainThread:@selector(executeAndReturnError:) withObject:nil waitUntilDone:YES];
	[as release];
	//[RemoteController playVolumeSound];
}

+(void)volumeDown
{
	NSAppleScript *as = [[NSAppleScript alloc] initWithSource:@"\nset curVolume to output volume of (get volume settings)\nif curVolume > 10 then\nset newVolume to curVolume - 10\nset volume output volume newVolume\nelse\nset newVolume to 1\nset volume output volume newVolume\nset volume output muted true\nend if\n"];
	[as performSelectorOnMainThread:@selector(executeAndReturnError:) withObject:nil waitUntilDone:YES];
	[as release];
	//[RemoteController playVolumeSound];
}

@end
