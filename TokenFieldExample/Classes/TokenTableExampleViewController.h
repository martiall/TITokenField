//
//  Created by jac on 9/14/12.
//


#import <Foundation/Foundation.h>
#import "TITokenTableViewController.h"


@interface TokenTableExampleViewController : TITokenTableViewController <TITokenTableViewDataSource, TITokenTableViewControllerDelegate, UITextViewDelegate> {


    NSArray *_tokenFieldTitlesAll;
    NSArray *_tokenFieldTitlesCompact;
    UITextView * _messageView;
    UITextField *_textFieldSubject;

    CGFloat _oldHeight;


}

@end