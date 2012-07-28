// LimeChat is copyrighted free software by Satoshi Nakagawa <psychs AT limechat DOT net>.
// You can redistribute it and/or modify it under the terms of the GPL version 2 (see the file GPL.txt).

#import "HostResolver.h"


@implementation HostResolver
{
    __weak id delegate;
}

@synthesize delegate;

- (id)initWithDelegate:(id)aDelegate
{
    self = [super init];
    if (self) {
        delegate = aDelegate;
    }
    return self;
}

- (void)resolve:(NSString*)hostname
{
    if (hostname.length) {
        [NSThread detachNewThreadSelector:@selector(resolveInternal:) toTarget:self withObject:hostname];
    }
}

- (void)resolveInternal:(NSString*)hostname
{
    [self retain];
    
    NSAutoreleasePool* pool = [NSAutoreleasePool new];
    
    NSHost* host = [NSHost hostWithName:hostname];
    NSArray* info = @[hostname, host];
    [self performSelectorOnMainThread:@selector(hostResolved:) withObject:info waitUntilDone:YES];
    
    [pool release];
    
    [self release];
}

- (void)hostResolved:(NSArray*)info
{
    if (!delegate) return;
    
    if ([info count] == 2) {
        NSHost* host = info[1];
        if ([delegate respondsToSelector:@selector(hostResolver:didResolve:)]) {
            [delegate hostResolver:self didResolve:host];
        }
    }
    else {
        NSString* hostname = info[0];
        if ([delegate respondsToSelector:@selector(hostResolver:didNotResolve:)]) {
            [delegate hostResolver:self didNotResolve:hostname];
        }
    }
}

@end
