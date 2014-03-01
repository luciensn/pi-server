//
//  ViewController.h
//

@import UIKit;

@interface ViewController : UIViewController <NSURLConnectionDataDelegate>

// IBOutlets
@property (weak, nonatomic) IBOutlet UITextField *destinationTextField;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;

// Properties
@property (nonatomic) BOOL requesting;

// IBActions
- (IBAction)sendRequest:(id)sender;

@end
