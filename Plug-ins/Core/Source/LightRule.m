//
//  LightRule.m
//  ControlPlane
//
//  Created by David Jennes on 30/09/11.
//  Copyright 2011. All rights reserved.
//

#import "LightRule.h"
#import "SensorsSource.h"

@implementation LightRule

- (id) init {
	self = [super init];
	ZAssert(self, @"Unable to init super '%@'", NSStringFromClass(super.class));
	if (!self) return nil;
	
	m_above = YES;
	m_treshold = -1.0;
	
	return self;
}

#pragma mark - Source observe functions

- (void) lightLevelChangedWithOld: (double) oldLevel andNew: (double) newLevel {
	if (m_above)
		self.match = (m_treshold <= newLevel);
	else
		self.match = (m_treshold > newLevel);
}

#pragma mark - Required implementation of 'Rule' class

- (NSString *) name {
	return NSLocalizedString(@"Ambient Light", @"Rule type");
}

- (NSString *) category {
	return NSLocalizedString(@"Sensors", @"Rule category");
}

- (NSString *) helpText {
	return NSLocalizedString(@"Ambient light level is", @"LightRule");
}

- (NSArray *) observedSources {
	return [NSArray arrayWithObject: SensorsSource.class];
}

- (void) loadData: (id) data {
	m_treshold = [[data objectForKey: @"treshold"] doubleValue];
	m_above = [[data objectForKey: @"above"] boolValue];
}

- (NSString *) describeValue: (id) value {
	if ([[value objectForKey: @"above"] boolValue])
		return [NSString stringWithFormat:
				NSLocalizedString(@"Above %d%%", @"LightRule value description"),
				[value valueForKey: @"treshold"]];
	else
		return [NSString stringWithFormat:
				NSLocalizedString(@"Below %d%%", @"LightRule value description"),
				[value valueForKey: @"treshold"]];
}

- (NSArray *) suggestedValues {
	SensorsSource *source = (SensorsSource *) [SourcesManager.sharedSourcesManager getSource: SensorsSource.class];
	BOOL above = source.lightLevel >= 0.5;
	
	// convert to dictionary
	return [NSArray arrayWithObject:
			[NSDictionary dictionaryWithObjectsAndKeys:
			 [NSNumber numberWithDouble: 0.5], @"treshold",
			 [NSNumber numberWithBool: above], @"above",
			 nil]];
}

@end
