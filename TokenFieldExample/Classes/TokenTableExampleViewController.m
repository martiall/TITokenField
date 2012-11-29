//
//  Created by jac on 9/14/12.
//


#import "TokenTableExampleViewController.h"
#import "TITokenContact.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
//#import "Names.h"

#define kOtherCellSubject 0
#define kOtherCellBody 1
#define kOtherCellCount 2


#define kOtherCellBodyHeight 300

@interface TokenTableExampleViewController ()<ABPeoplePickerNavigationControllerDelegate>
@property (nonatomic) BOOL showCompactFields;
@end

@implementation TokenTableExampleViewController

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
	self.currentSelectedTokenField = self.lastSelectedTokenField;
	[peoplePicker dismissModalViewControllerAnimated:YES];
}

// Called after a person has been selected by the user.
// Return YES if you want the person to be displayed.
// Return NO  to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	ABMutableMultiValueRef emailsValue = ABRecordCopyValue(person, kABPersonEmailProperty);
	if(emailsValue == nil) {
		return NO;
	}
	CFIndex emailCount = ABMultiValueGetCount(emailsValue);
	CFRelease(emailsValue);
	
	return (emailCount > 0);
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
	NSString *firstNameValue = (NSString *)CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
	NSString *lastNameValue = (NSString *)CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
	NSString *contactName = nil;
	if(ABPersonGetCompositeNameFormat() == kABPersonCompositeNameFormatFirstNameFirst)
		contactName = [NSString stringWithFormat:@"%@ %@", firstNameValue, lastNameValue];
	else
		contactName = [NSString stringWithFormat:@"%@ %@", lastNameValue, firstNameValue];
	
	ABMutableMultiValueRef multiValue = ABRecordCopyValue(person, property);
	CFIndex dataIndex = ABMultiValueGetIndexForIdentifier(multiValue, identifier);
	NSString* email = (NSString *)CFBridgingRelease(ABMultiValueCopyValueAtIndex(multiValue, dataIndex));

	CFRelease(multiValue);

	TIToken * token = [self.lastSelectedTokenField addTokenWithTitle:contactName representedObject:email];
	[token setAccessoryType:TITokenAccessoryTypeNone];
	// If the size of the token might change, it's a good idea to layout again.
	[self.currentSelectedTokenField layoutTokensAnimated:YES];
	
	NSUInteger tokenCount = self.lastSelectedTokenField.tokens.count;
	[token setTintColor:((tokenCount % 3) == 0 ? [TIToken redTintColor] : ((tokenCount % 2) == 0 ? [TIToken greenTintColor] : [TIToken blueTintColor]))];
	
	self.currentSelectedTokenField = self.lastSelectedTokenField;
	[peoplePicker dismissModalViewControllerAnimated:YES];	
	
	return NO;
}

- (id)init {
    self = [super init];
    if (self) {
        _tokenFieldTitlesAll = @[@"To:", @"Cc:", @"Bcc:"];
		_tokenFieldTitlesCompact = @[@"To:"];
        _oldHeight = kOtherCellBodyHeight;
    }
	
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	//
	UIBarButtonItem *dismissKeyboard =
	[[UIBarButtonItem alloc] initWithTitle:@"Dismiss KB"
									 style:UIBarButtonItemStylePlain
									target:self
									action:@selector(dismissKeyboard:)];
	[self.navigationItem setRightBarButtonItem:dismissKeyboard];
	
	UIBarButtonItem *toggleCCVisibility =
	[[UIBarButtonItem alloc] initWithTitle:@"Toggle CC"
									 style:UIBarButtonItemStylePlain
									target:self
									action:@selector(toggleCCVisibility:)];
	[self.navigationItem setLeftBarButtonItem:toggleCCVisibility];
	
	CFErrorRef myError = NULL;
	ABAddressBookRef myAddressBook = ABAddressBookCreateWithOptions(NULL, &myError);
    ABAddressBookRequestAccessWithCompletion(myAddressBook,
											 ^(bool granted, CFErrorRef error) {
												 if (granted) {
													 NSArray *allPeoples = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(myAddressBook));
													 NSMutableArray *peoplesWithEmail = [NSMutableArray new];
													 [allPeoples enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
														 ABMutableMultiValueRef emailsValue = ABRecordCopyValue((__bridge ABRecordRef)obj, kABPersonEmailProperty);
														 if(emailsValue == nil) {
															 return;
														 }
														 CFIndex emailCount = ABMultiValueGetCount(emailsValue);
														 if(emailCount != 0) {
															 NSString *firstNameValue = (NSString *)CFBridgingRelease(ABRecordCopyValue((__bridge ABRecordRef)obj, kABPersonFirstNameProperty));
															 NSString *lastNameValue = (NSString *)CFBridgingRelease(ABRecordCopyValue((__bridge ABRecordRef)obj, kABPersonLastNameProperty));
															 NSString *contactName = nil;
															 if(ABPersonGetCompositeNameFormat() == kABPersonCompositeNameFormatFirstNameFirst)
																 contactName = [NSString stringWithFormat:@"%@ %@", firstNameValue, lastNameValue];
															 else
																 contactName = [NSString stringWithFormat:@"%@ %@", lastNameValue, firstNameValue];
															 
															 
															 for(int index = 0; index < emailCount; index++) {
																 NSString *identifierValue = (NSString *)CFBridgingRelease(ABMultiValueCopyLabelAtIndex(emailsValue, index));
																 NSString *emailValue = (NSString *)CFBridgingRelease(ABMultiValueCopyValueAtIndex(emailsValue, index));
																 
																 [peoplesWithEmail addObject:[TITokenContact contactWithName:contactName email:emailValue label:identifierValue]];
															 }
														 }
														 CFRelease(emailsValue);
													 }];
													 [self setSourceArray:peoplesWithEmail];
												 } else {
													 // Handle the error
												 }
												 CFRelease(myAddressBook);
											 });
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self _recalculateHeightOfTextView:_messageView];
}


#pragma mark - Bar buttons

- (void)dismissKeyboard:(id)object
{
	[self.view endEditing:YES];
}

- (void)toggleCCVisibility:(id)object
{
	self.showCompactFields = !self.showCompactFields;
}

#pragma mark - Hiding of fields

- (void)setShowCompactFields:(BOOL)showCompactFields
{
	if (_showCompactFields != showCompactFields)
	{
		_showCompactFields = showCompactFields;
		
		NSIndexPath *CCRow =
		[NSIndexPath indexPathForRow:1 inSection:0];
		
		NSIndexPath *BCCRow =
		[NSIndexPath indexPathForRow:2 inSection:0];
		
		if (showCompactFields)
		{
			[self.tableView deleteRowsAtIndexPaths:@[CCRow, BCCRow]
								  withRowAnimation:UITableViewRowAnimationAutomatic];
		}
		
		else
		{
			[self.tableView insertRowsAtIndexPaths:@[CCRow, BCCRow]
								  withRowAnimation:UITableViewRowAnimationAutomatic];
		}
	}
}

#pragma mark - TITokenFieldDelegate

- (NSString *)tokenField:(TITokenField *)tokenField displayStringForRepresentedObject:(id)object
{
	if ([object respondsToSelector:@selector(fullName)])
		return [object fullName];
	
	return [object description];
}

- (NSString *)tokenField:(TITokenField *)tokenField searchResultStringForRepresentedObject:(id)object
{
	if ([object respondsToSelector:@selector(fullName)])
		return [object fullName];
	
	return [object description];
}

- (NSString *)tokenField:(TITokenField *)tokenField searchResultSubtitleForRepresentedObject:(id)object
{
	if ([object respondsToSelector:@selector(email)])
		return [object email];
	
	return [object description];
}

#pragma mark - TokenTableViewDataSource

- (NSString *)tokenFieldPromptAtRow:(NSUInteger)row {
	if (self.showCompactFields)
		return _tokenFieldTitlesCompact[row];
	
    return _tokenFieldTitlesAll[row];
}

- (NSUInteger)numberOfTokenRows {
	if (self.showCompactFields)
		return _tokenFieldTitlesCompact.count;
	
    return _tokenFieldTitlesAll.count;
}

- (UIView *)accessoryViewForField:(TITokenField *)tokenField {
	
    UIButton * addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
   	[addButton addTarget:self action:@selector(showContactsPicker:) forControlEvents:UIControlEventTouchUpInside];
   	[tokenField setRightView:addButton];
	
    return addButton;
}


#pragma mark - TokenTableViewDataSource (Other table cells)

- (CGFloat)tokenTableView:(TITokenTableViewController *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    switch (indexPath.row) {
        case kOtherCellSubject:
            return 44;
        case kOtherCellBody:
            return _oldHeight;
        default:
            return 0;
    }
}


- (NSInteger)tokenTableView:(TITokenTableViewController *)tableView numberOfRowsInSection:(NSInteger)section {
    return kOtherCellCount;
}


- (UITableViewCell *)tokenTableView:(TITokenTableViewController *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
	
	
    static NSString *CellIdentifierSubject = @"SubjectCell";
    static NSString *CellIdentifierBody = @"BodyCell";
	
    // todo save the cells to keep their text active
    switch (indexPath.row) {
        case kOtherCellSubject:
            cell = [tableView.tableView dequeueReusableCellWithIdentifier:CellIdentifierSubject];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierSubject];
                if(!_textFieldSubject) {
                    //UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, cell.frame.size.height / 2 - textView.font.lineHeight, tableView.tableView.bounds.size.width, 30)];
                    _textFieldSubject = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
					CGRect subjectFrame = CGRectMake(10, cell.frame.size.height / 2 - _textFieldSubject.font.lineHeight / 2, tableView.tableView.bounds.size.width, 30);
                    _textFieldSubject.frame = CGRectIntegral(subjectFrame);
                    _textFieldSubject.placeholder = @"Subject";
					_textFieldSubject.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                }
				
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				[cell.contentView addSubview:_textFieldSubject];
            }
            break;
			
        case kOtherCellBody:
            cell = [tableView.tableView dequeueReusableCellWithIdentifier:CellIdentifierBody];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierBody];
                cell.frame = CGRectMake(0, 0, cell.frame.size.width, kOtherCellBodyHeight);
                if (!_messageView) {
                    _messageView = [[UITextView alloc] initWithFrame:cell.frame];
                   	[_messageView setScrollEnabled:NO];
                   	[_messageView setAutoresizingMask:UIViewAutoresizingNone];
                   	[_messageView setDelegate:self];
                   	[_messageView setFont:[UIFont systemFontOfSize:15]];
                   	[_messageView setText:@"Some message. The whole view resizes as you type, not just the text view."];
					
					_messageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                }
				
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				[cell.contentView addSubview:_messageView];
            }
            break;
			
        default:
            break;
    }
	
    return cell;
	
}

- (void)showContactsPicker:(id)sender {
	self.lastSelectedTokenField = self.currentSelectedTokenField;
	
	ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
	peoplePicker.peoplePickerDelegate = self;
	peoplePicker.displayedProperties = @[ @(kABPersonFirstNameProperty), @(kABPersonLastNameProperty), @(kABPersonEmailProperty) ];

	[self.navigationController presentModalViewController:peoplePicker animated:YES];
	// Show some kind of contacts picker in here.
	// For now, here's how to add and customize tokens.
	
	//	NSArray * names = [Names listOfNames];
	//
	//	TITokenContact *contact =
	//	names[(arc4random() % names.count)];
	//
	//	TIToken * token =
	//	[self.currentSelectedTokenField addTokenWithTitle:contact.fullName representedObject:contact.email];
	//	[token setAccessoryType:TITokenAccessoryTypeDisclosureIndicator];
	//	// If the size of the token might change, it's a good idea to layout again.
	//	[self.currentSelectedTokenField layoutTokensAnimated:YES];
	//
	//	NSUInteger tokenCount = self.currentSelectedTokenField.tokens.count;
	//	[token setTintColor:((tokenCount % 3) == 0 ? [TIToken redTintColor] : ((tokenCount % 2) == 0 ? [TIToken greenTintColor] : [TIToken blueTintColor]))];
}


#pragma mark - TokenTableViewControllerDelegate

- (void)textViewDidChange:(UITextView *)textView
{
	[self _recalculateHeightOfTextView:textView];
}

- (void)_recalculateHeightOfTextView:(UITextView *)textView
{
	CGFloat newHeight = textView.contentSize.height + textView.font.lineHeight;
	
    if (newHeight < kOtherCellBodyHeight) {
        newHeight = kOtherCellBodyHeight;
    }
	
	CGRect newTextFrame = textView.frame;
	newTextFrame.size = textView.contentSize;
	newTextFrame.size.height = newHeight;
	
	[textView setFrame:newTextFrame];
	
    _oldHeight = newHeight;
	
    [self updateContentSize];
}


@end
