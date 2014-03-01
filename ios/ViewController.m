//
//  ViewController.m
//

#import "ViewController.h"

static NSString *const DESTINATION = @"DESTINATION";
static NSString *const MESSAGE = @"MESSAGE";

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *savedDestination = [[NSUserDefaults standardUserDefaults] stringForKey:DESTINATION];
    if (savedDestination) {
        [_destinationTextField setText:savedDestination];
    }
    
    NSString *savedMessage = [[NSUserDefaults standardUserDefaults] stringForKey:MESSAGE];
    if (savedMessage) {
        [_messageTextField setText:savedMessage];
    }
}

#pragma mark - Actions

- (IBAction)sendRequest:(id)sender {
    if (_requesting) {
        return;
    }
    [self setRequesting:YES];
    
    NSString *destination = _destinationTextField.text;
    if (destination.length > 0) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        // save the destination string
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:destination forKey:DESTINATION];
        [defaults synchronize];
        
        // save the message string
        NSString *message = _messageTextField.text;
        if (message.length > 0) {
            [defaults setObject:message forKey:MESSAGE];
            [defaults synchronize];
        }
        
        // create the request
        NSString *urlString = [NSString stringWithFormat:@"http://%@", destination];
        NSURL *url = [NSURL URLWithString:urlString];
        NSTimeInterval timeout = 8.0;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setCachePolicy:NSURLCacheStorageNotAllowed];
        [request setTimeoutInterval:timeout];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        
        // add the message to the request body
        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        
        // begin the URL connection
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        [conn start];
    }
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger responseStatusCode = [httpResponse statusCode];
    NSLog(@"Response Receieved: %ld", (long)responseStatusCode);
    if (responseStatusCode != 200) {
        [self showErrorAlertMessageWithTitle:@"Error!" message:@"Invalid request."];
    }
    [self finish];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed with error: %@", error);
    [self showErrorAlertMessageWithTitle:@"Error!" message:@"Connection failed."];
    [self finish];
}

#pragma mark - 

- (void)finish {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self setRequesting:NO];
}

- (void)showErrorAlertMessageWithTitle:(NSString *)title message:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
