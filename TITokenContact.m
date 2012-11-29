//
//  TITokenContact.m
//  TokenFieldExample
//
//  Created by Lin Junjie on 13/11/12.
//
//

#import "TITokenContact.h"

@implementation TITokenContact

+ (id)contactWithName:(NSString *)name
				email:(NSString *)email
				label:(NSString *)label
{
	TITokenContact *contact =
	[[TITokenContact alloc] initWithName:name email:email label:label];
	
	return contact;
}

- (id)init
{
	return [self initWithName:@"" email:@"" label:@""];
}

- (id)initWithName:(NSString *)name
			 email:(NSString *)email
			 label:(NSString *)label
{
	self = [super init];
	
	if (self)
	{
		_fullName = [name copy];
		_email = [email copy];
		_label = [label copy];
	}
	
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"TITokenContact: %@ (%@, %@)",
			self.fullName, self.email, self.label];
}

@end
