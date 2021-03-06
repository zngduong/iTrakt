#import "AuthenticationViewController.h"
#import "Trakt.h"
#import "SSKeychain.h"
#import <QuartzCore/QuartzCore.h>

@implementation AuthenticationViewController


+ (BOOL)signIn {
  NSString *username, *password;
  [self retrieveUsername:&username password:&password];
  if (username && password) {
    [self authenticate:username password:password];
    return YES;
  }
  return NO;
}

+ (NSString *)signedInAs {
  return [[NSUserDefaults standardUserDefaults] objectForKey:@"Username"];
}

+ (void)retrieveUsername:(NSString **)username password:(NSString **)password {
  *password = nil;
  *username = [self signedInAs];
  if (*username) {
    *password = [SSKeychain passwordForService:@"iTrakt" account:*username];
  }
}

+ (void)saveAndAuthenticate:(NSString *)username password:(NSString *)password {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setValue:username forKey:@"Username"]; // TODO move to constant
  [defaults synchronize];
  [SSKeychain setPassword:password forService:@"iTrakt" account:username];
  [self authenticate:username password:password];
}

+ (void)authenticate:(NSString *)username password:(NSString *)password {
  [[Trakt sharedInstance] setApiUser:username];
  [[Trakt sharedInstance] setApiPassword:password];
}


@synthesize delegate;
@synthesize tableView;
@synthesize usernameField, passwordField;
@synthesize usernameCell, passwordCell;
@synthesize signingInCell, signedInCell, signedInAsLabel;
@synthesize doneButton, helpBannerButton;


- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  signingIn = NO;
  signedIn = NO;

  NSString *username, *password;
  [AuthenticationViewController retrieveUsername:&username password:&password];
  self.usernameField.text = username;
  self.passwordField.text = password;

  if (username && password) {
    self.helpBannerButton.hidden = YES;
  }

  UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
  backView.backgroundColor = [UIColor clearColor];
  self.signingInCell.backgroundView = backView;
  self.signedInCell.backgroundView = backView;
  [backView release];

  [self textDidChange:nil];
}


- (void)dealloc {
  self.tableView = nil;
  self.usernameField = nil;
  self.passwordField = nil;
  self.usernameCell = nil;
  self.passwordCell = nil;
  self.signingInCell = nil;
  self.signedInCell = nil;
  self.signedInAsLabel = nil;
  self.doneButton = nil;
  self.helpBannerButton = nil;
  [super dealloc];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return signingIn || signedIn ? 2 : 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if ((signingIn || signedIn) && section == 0) {
    return 1;
  } else {
    return 2;
  }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (signingIn && indexPath.section == 0) {
    return self.signingInCell;
  } else if (signedIn && indexPath.section == 0) {
    self.signedInAsLabel.text = [NSString stringWithFormat:@"Signed in as ‘%@’", [[self class] signedInAs]];
    return self.signedInCell;
  } else {
    if (indexPath.row == 0) {
      return self.usernameCell;
    } else {
      return self.passwordCell;
    }
  }
}


- (IBAction)dismissDialog:(id)sender {
  [self.delegate authenticationViewWillDismiss:self];
  [self.parentViewController dismissModalViewControllerAnimated:YES];
}


- (IBAction)saveCredentials:(id)sender {
  [self.usernameField resignFirstResponder];
  [self.passwordField resignFirstResponder];

  self.doneButton.enabled = NO;
  self.usernameField.enabled = NO;
  self.passwordField.enabled = NO;

  NSString *username = self.usernameField.text;
  NSString *password = self.passwordField.text;

  [AuthenticationViewController saveAndAuthenticate:username password:password];

  signingIn = YES;
  [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0]
                withRowAnimation:UITableViewRowAnimationTop];

  [[Trakt sharedInstance] verifyCredentials:^(BOOL valid) {
    if (valid) {
      signingIn = NO;
      [self dismissDialog:self];
    } else {
      NSLog(@"FAIL!");
      self.doneButton.enabled = YES;
      self.usernameField.enabled = YES;
      self.passwordField.enabled = YES;
    }
  }];
}


- (IBAction)textDidChange:(id)sender {
  self.doneButton.enabled = self.usernameField.text.length > 0 && self.passwordField.text.length > 0;
  if (self.passwordField.text.length == 0) {
    self.helpBannerButton.hidden = NO;
  }
  if (self.usernameField.text.length > 0 || self.passwordField.text.length > 0) {
    // TODO Ideally this would have a transition animation
    [self.helpBannerButton setTitle:@"Forgot your password?" forState:UIControlStateNormal];
  } else {
    [self.helpBannerButton setTitle:@"Don’t have an account yet?" forState:UIControlStateNormal];
  }
}

- (IBAction)selectPasswordField:(id)sender {
  [self.passwordField becomeFirstResponder];
}


// TODO open forgot password URL
- (IBAction)openTraktSite:(id)sender {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://trakt.tv/join"]];
}


@end

