#import "RootViewController.h"
#import "BroadcastDate.h"
#import "EpisodeTableViewCell.h"
#import "Episode.h"

@implementation RootViewController

@synthesize broadcastDates;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    CGFloat tableViewWidth = self.tableView.bounds.size.width;
    self.tableView.rowHeight = [EpisodeTableViewCell heightForWidth:tableViewWidth];

    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor = [UIColor darkGrayColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;

    Episode *ep1 = [[Episode alloc] initWithTitle:@"Doctor Who" season:4 number:2 banner:[UIImage imageNamed:@"banner.jpg"]];
    Episode *ep2 = [[Episode alloc] initWithTitle:@"Fringe" season:2 number:6 banner:[UIImage imageNamed:@"banner.jpg"]];

    BroadcastDate *date1 = [[BroadcastDate alloc] initWithDate:[NSDate distantPast] episodes:[NSArray arrayWithObjects:ep1, nil]];
    BroadcastDate *date2 = [[BroadcastDate alloc] initWithDate:[NSDate distantFuture] episodes:[NSArray arrayWithObjects:ep2, nil]];

    self.broadcastDates = [NSArray arrayWithObjects: date1, date2, nil];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

/*
- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Return YES for supported orientations.
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [broadcastDates count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    BroadcastDate *broadcastDate = [broadcastDates objectAtIndex:section];

    return [broadcastDate.episodes count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  BroadcastDate *broadcastDate = [broadcastDates objectAtIndex:section];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

  [dateFormatter setDateFormat:@"EEEE MMMM d"];

  return [dateFormatter stringFromDate:broadcastDate.date];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellIdentifier = @"episodeCell";
  EpisodeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil) {
    CGRect frame = CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, self.tableView.rowHeight);
    cell = [[[EpisodeTableViewCell alloc] initWithFrame:frame reuseIdentifier:cellIdentifier] autorelease];
  }

  BroadcastDate *broadcastDate = [broadcastDates objectAtIndex:indexPath.section];
  Episode *episode = [broadcastDate.episodes objectAtIndex:indexPath.row];
  cell.episode = episode;

  return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  /*
   <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
   [self.navigationController pushViewController:detailViewController animated:YES];
   [detailViewController release];
   */
}

// TODO this is where we should deliver our own section headers
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  //return 50.0;
//}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  //UIToolbar *bar = [UIToolbar new];
  //bar.barStyle = UIBarStyleBlack;
  //UIBarButtonItem *label = [UIBarButtonItem new];
  //label.style = UIBarButtonItemStylePlain;
  //label.enabled = NO;
  //label.title = @"FOO";
  //bar.items = [NSArray arrayWithObject:label];
  //return bar;
//}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

