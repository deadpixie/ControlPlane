//
//	AudioOutputRule.m
//	ControlPlane
//
//	Created by David Jennes on 24/09/11.
//	Copyright 2011. All rights reserved.
//

#import "AudioOutputRule.h"
#import "AudioSource.h"
#import <IOKit/audio/IOAudioTypes.h>

@implementation AudioOutputRule

- (id) init {
	self = [super init];
	ZAssert(self, @"Unable to init super '%@'", NSStringFromClass(super.class));
	if (!self) return nil;
	
	m_output = nil;
	
	return self;
}

#pragma mark - Source observe functions

- (void) outputChangedWithOld: (NSNumber *) oldOutput andNew: (NSNumber *) newOutput {
	self.match = [m_output isEqualToNumber: newOutput];
}

#pragma mark - Required implementation of 'Rule' class

- (NSString *) name {
	return NSLocalizedString(@"Audio Output", @"Rule type");
}

- (NSString *) category {
	return NSLocalizedString(@"System", @"Rule category");
}

- (NSString *) helpText {
	return NSLocalizedString(@"Audio output going to", @"AudioOutputRule");
}

- (NSArray *) observedSources {
	return [NSArray arrayWithObject: AudioSource.class];
}

- (void) loadData: (id) data {
	m_output = data;
}

- (NSString *) describeValue: (id) value {
	AudioSource *source = (AudioSource *) [SourcesManager.sharedSourcesManager getSource: AudioSource.class];
	NSString *name = [source.devices objectForKey: value];
	
	if (name)
		return name;
	else
		return NSLocalizedString(@"Unknown Device", @"AudioOutputRule value description");
}

- (NSArray *) suggestedValues {
	AudioSource *source = (AudioSource *) [SourcesManager.sharedSourcesManager getSource: AudioSource.class];
	NSMutableArray *result = [NSMutableArray new];
	NSString *typeName = NSLocalizedString(@"output", @"AudioSource");
	
	// loop through devices
	for (NSNumber *device in source.devices)
		// only output devices
		if ([[source.devices objectForKey: device] rangeOfString: typeName].location != NSNotFound)
			[result addObject: device];
	
	return result;
}

@end
