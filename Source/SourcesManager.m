//
//  SourcesManager.m
//  ControlPlane
//
//  Created by David Jennes on 18/09/11.
//  Copyright 2011. All rights reserved.
//

#import "Rule.h"
#import "Source.h"
#import "SourcesManager.h"
#import "SynthesizeSingleton.h"

@interface SourcesManager (Private)

- (void) createSources;

@end

@implementation SourcesManager

SYNTHESIZE_SINGLETON_FOR_CLASS(SourcesManager);

- (id) init {
	ZAssert(!sharedSourcesManager, @"This is a singleton, use %@.shared%@", NSStringFromClass(self.class), NSStringFromClass(self.class));
	
	self = [super init];
	ZAssert(self, @"Unable to init super '%@'", NSStringFromClass(super.class));
	
	m_sources = [NSMutableDictionary new];
	m_sourceTypes = [NSMutableArray new];
	m_sourcesCreated = NO;
	
	return self;
}

- (void) dealloc {
	[m_sources release];
	[m_sourceTypes release];
	
	[super dealloc];
}

#pragma mark - Source types

- (void) registerSourceType: (Class) type {
	[m_sourceTypes addObject: type];
}

- (void) createSources {
	Source *source = nil;
	
	// create an instance of each source type
	for (Class type in m_sourceTypes) {
		source = [[type new] autorelease];
		[m_sources setObject: source forKey: source.name];
	}
	
	m_sourcesCreated = YES;
}

#pragma mark - Rules registration

- (Source *) registerRule: (Rule *) rule toSource: (NSString *) source {
	if (!m_sourcesCreated)
		[self createSources];
	
	// find it
	Source *sourceInstance = [self getSource: source];
	ZAssert(sourceInstance != nil, @"Unknown source: %@", source);
	
	// register
	[sourceInstance addObserver: rule];
	sourceInstance.listenersCount++;
	
	return sourceInstance;
}

- (void) unRegisterRule: (Rule *) rule fromSource: (NSString *) source {
	if (!m_sourcesCreated)
		[self createSources];
	
	Source *sourceInstance = [self getSource: source];
	ZAssert(sourceInstance != nil, @"Unknown source: %@", source);
	ZAssert(sourceInstance.listenersCount > 0, @"Source has no listeners!");
	
	[sourceInstance removeObserver: rule];
	sourceInstance.listenersCount--;
}

#pragma mark - Other functions

- (Source *) getSource: (NSString *) name {
	return [m_sources objectForKey: name];
}

@end
