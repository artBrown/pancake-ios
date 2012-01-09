//
//  ListViewController.m
//  iSugarCRM
//
//  Created by Ved Surtani on 06/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ListViewController.h"
#import "ListViewMetadata.h"
#import "SugarCRMMetadataStore.h"
#import "DBSession.h"
#import "DataObject.h"
#import "DetailViewController.h"
@implementation ListViewController
@synthesize moduleName,datasource,metadata;
+(ListViewController*)listViewControllerWithMetadata:(ListViewMetadata*)metadata
{
    ListViewController *lViewController = [[ListViewController alloc] init];
    lViewController.metadata = metadata;
    lViewController.moduleName = metadata.moduleName;
    return lViewController;

}

+(ListViewController*)listViewControllerWithModuleName:(NSString*)module
{
    ListViewController *lViewController = [[ListViewController  alloc] init];
    //lViewController.moduleName = module;
    return lViewController;
}

-(id)init{
    if (self=[super init]) {
        myTableView = [[UITableView alloc] init];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    datasource = [[NSMutableArray alloc] init];
    if (!metadata) {
      self.metadata = [[SugarCRMMetadataStore sharedInstance]listViewMetadataForModule:moduleName];
    }
    myTableView = [[UITableView alloc] init];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.frame = [[UIScreen mainScreen] applicationFrame];
    CGFloat rowHeight = 20.f + [[metadata otherFields] count] *15 + 10;
    myTableView.rowHeight = rowHeight>51.0?rowHeight:51.0f;
    self.view = myTableView;
    
    SugarCRMMetadataStore *sharedInstance = [SugarCRMMetadataStore sharedInstance];
    DBMetadata *dbMetadata = [sharedInstance dbMetadataForModule:metadata.moduleName];
    DBSession * dbSession = [DBSession sessionWithMetadata:dbMetadata];
    dbSession.delegate = self;
    [dbSession startLoading];
}
#pragma mark DBLoadSession Delegate;
-(void)session:(DBSession *)session downloadedModuleList:(NSArray *)moduleList moreComing:(BOOL)moreComing
{   
    datasource = moduleList;
    [myTableView reloadData];
}
-(void)session:(DBSession *)session listDownloadFailedWithError:(NSError *)error
{
    NSLog(@"Error: %@",[error localizedDescription]);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [datasource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    id dataObjectForRow = [datasource objectAtIndex:indexPath.row];
  
    cell.textLabel.text = [dataObjectForRow objectForFieldName:metadata.primaryDisplayField.name];
    
    for(DataObjectField *otherField in metadata.otherFields)
    {
    NSLog(@"field key %@",otherField.name);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@",otherField.label,[dataObjectForRow objectForFieldName:otherField.name]];
          NSLog(@"other display field %@ label:%@",[dataObjectForRow objectForFieldName:otherField.name],otherField.label);
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    // Navigation logic may go here. Create and push another view controller.
    id beanTitle = [[datasource objectAtIndex:indexPath.row] objectForFieldName:@"name"];
    id beanId =[[datasource objectAtIndex:indexPath.row]objectForFieldName:@"id"];
    NSLog(@"beanId %@, beantitle %@",beanId,beanTitle);
                
    DetailViewController *detailViewController = [DetailViewController detailViewcontroller:[[SugarCRMMetadataStore sharedInstance] detailViewMetadataForModule:metadata.moduleName] beanId:beanId beanTitle:beanTitle];
     [self.navigationController pushViewController:detailViewController animated:YES];
   }
@end