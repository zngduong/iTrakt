#import "SeasonsViewController.h"
#import "Season.h"
#import "Episode.h"
#import "EpisodeDetailsViewController.h"
#import "HTTPDownload.h"
#import "CheckboxCell.h"

@implementation SeasonsViewController

@synthesize show;
@synthesize seasons;


#pragma mark -
#pragma mark View lifecycle

- (id)initWithShow:(Show *)theShow {
  if (self = [super initWithNibName:@"SeasonsViewController" bundle:nil]) {
    self.show = theShow;
    self.navigationItem.title = @"Episodes";
  }
  return self;
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if (show.seasons == nil) {
    [show ensureSeasonsAreLoaded:^{
      self.seasons = show.seasons;
      [self.tableView reloadData];
    }];
  } else {
    self.seasons = show.seasons;
    [self.tableView reloadData];
  }
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return (seasons == nil) ? 0 : [seasons count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (seasons == nil) {
    return 0;
  } else {
    Season *season = [seasons objectAtIndex:section];
    return [season.episodes count];
  }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (seasons == nil) {
    return nil;
  } else {
    Season *season = [seasons objectAtIndex:section];
    return [season label];
  }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellIdentifier = @"checkboxCell";
  CheckboxCell *cell = (CheckboxCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

  if (cell == nil) {
    cell = [[[CheckboxCell alloc] initWithReuseIdentifier:cellIdentifier delegate:self disclosureAccessory:YES] autorelease];
  }

  Season *season = [seasons objectAtIndex:indexPath.section];
  Episode *episode = [season.episodes objectAtIndex:indexPath.row];
  [cell setSelected:episode.seen text:episode.title];
  return cell;
}


- (void)checkboxClicked:(Checkbox *)checkbox {
  CheckboxCell *cell = (CheckboxCell *)checkbox.superview.superview;
  NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
  Season *season = [seasons objectAtIndex:indexPath.section];
  Episode *episode = [season.episodes objectAtIndex:indexPath.row];
  checkbox.selected = !episode.seen;
  [episode toggleSeen:^{
    checkbox.selected = episode.seen;
  }];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  Season *season = [seasons objectAtIndex:indexPath.section];
  Episode *episode = [season.episodes objectAtIndex:indexPath.row];
  EpisodeDetailsViewController *controller = [[EpisodeDetailsViewController alloc] initWithEpisode:episode];
  [self.navigationController pushViewController:controller animated:YES];
  [controller release];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];

  // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
  // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
  // For example: self.myOutlet = nil;
}


- (void)dealloc {
  [super dealloc];
  [show release];
  [seasons release];
}


@end

