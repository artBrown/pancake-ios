//
//  NearbyDealsListViewController.m
//  Deals
//
//  Created by Ved Surtani on 06/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import "EditViewController.h"
#import "DetailViewController.h"
#import "UITableViewCellSectionItem.h"
#import "UITableViewCellItem.h"
#import "SugarCRMMetadataStore.h"
#import "DataObject.h"
#import "DetailViewRowItem.h"
#import "DetailViewSectionItem.h"
#import "RelationsViewController.h"
#import "SyncHandler.h"
#import "AppDelegate.h"

@interface DetailViewController()
{
    UIToolbar *toolbar;
}
@property(strong) NSArray *detailsArray;
//@property(strong) NSMutableArray *detailsArray;
-(void) addToolbar;
@end

@implementation DetailViewController
@synthesize datasource,metadata,beanId,beanTitle;
@synthesize detailsArray; 

#pragma mark init methods

+(DetailViewController*)detailViewcontroller:(DetailViewMetadata*)metadata beanId:(NSString*)beanId beanTitle:(NSString*)beanTitle
{
    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    detailViewController.metadata = metadata;
    NSLog(@"module name %@",metadata.moduleName); //remove
    detailViewController.beanId = beanId;
    detailViewController.beanTitle = beanTitle;
    return detailViewController;
}

-(id)init{
    self = [super init];
    return self;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark DbSession Load Delegate methods

-(void)session:(DBSession *)session downloadedDetails:(NSArray *)details
{   
    self.detailsArray = [details mutableCopy];
    NSMutableArray* sections = [[NSMutableArray alloc] init];
    for(NSDictionary *sectionItem_ in metadata.sections  )
    {   
        DetailViewSectionItem *sectionItem = [[DetailViewSectionItem alloc] init];
        sectionItem.sectionTitle = [sectionItem_ objectForKey:@"section_name"];
        NSMutableArray *rowItems = [[NSMutableArray alloc] init];
        NSArray *rows = [sectionItem_ objectForKey:@"rows"];
        for(NSDictionary *rowItem_ in rows)
        {
            DetailViewRowItem *rowItem = [[DetailViewRowItem alloc] init];
            rowItem.label = [rowItem_ objectForKey:@"label"];
            //workaround for deteremining action type. pls resolve.
            rowItem.action = [(DataObjectField*)[[rowItem_ objectForKey:@"fields"] objectAtIndex:0] action];
        
            NSMutableArray *fields = [NSMutableArray array];
            for(DataObjectField *field in [rowItem_ objectForKey:@"fields"])
            {
                NSString *value = [[details objectAtIndex:0] objectForFieldName:field.name];
                if (value) 
                {
                    [fields addObject:value];    
                }
            }
            rowItem.values = fields;
            [rowItems addObject:rowItem];
        }
        sectionItem.rowItems = rowItems;
        [sections addObject:sectionItem];
    }
    self.datasource = sections;
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editDetails)];
    [self.tableView reloadData];
}
-(void)session:(DBSession *)session detailDownloadFailedWithError:(NSError *)error
{
    NSLog(@"Error: %@",[error localizedDescription]);
}


#pragma mark --
-(void)editDetails
{
    SugarCRMMetadataStore *metadataStore= [SugarCRMMetadataStore sharedInstance];
    NSLog(@"module name %@, metadata = %@",self.metadata.moduleName,[metadataStore objectMetadataForModule:self.metadata.moduleName]);
    EditViewController *editViewController = [EditViewController editViewControllerWithMetadata:[metadataStore objectMetadataForModule:self.metadata.moduleName] andDetailedData:(NSArray *)self.detailsArray];
    editViewController.title = @"Edit Record";
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:editViewController];
    navController.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentModalViewController:navController animated:YES];
}

-(void) loadDataFromDb
{
    if(self.beanId){
        SugarCRMMetadataStore *sharedInstance = [SugarCRMMetadataStore sharedInstance];
        DBMetadata *dbMetadata = [sharedInstance dbMetadataForModule:metadata.moduleName];
        DBSession * dbSession = [DBSession sessionWithMetadata:dbMetadata];
        dbSession.delegate = self;
        [dbSession loadDetailsForId:self.beanId];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
//<<<<<<< HEAD
    [super viewDidLoad];
    self.title = self.beanTitle;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editDetails)];
    [self loadDataFromDb];
/*=======
    SugarCRMMetadataStore *metadataStore= [SugarCRMMetadataStore sharedInstance];
    EditViewController *editViewController = [EditViewController editViewControllerWithMetadata:[metadataStore objectMetadataForModule:self.metadata.moduleName] andDetailedData:self.detailsArray];
    editViewController.title = @"Edit Record";
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:editViewController];
    navController.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentModalViewController:navController animated:YES];
>>>>>>> 45dbcf7ab016fbdcc3e6f5bb371d04e63c521a3a
 */
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
    [self loadDataFromDb];
    [self addToolbar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [toolbar removeFromSuperview];
    [self.navigationController setToolbarHidden:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
   
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGRect toolbarFrame = self.navigationController.toolbar.frame;
    toolbar.frame = CGRectMake(0, 0, toolbarFrame.size.width, toolbarFrame.size.height);
}

-(void) addToolbar
{
    CGRect toolbarFrame = self.navigationController.toolbar.frame;
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, toolbarFrame.size.width, toolbarFrame.size.height)];
    
    UIBarButtonItem* composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createButtonClicked:)];
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(editDetails)];
    UIBarButtonItem* deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteButtonClicked:)];
    deleteButton.image = [UIImage imageNamed:@"sync"];
    UIBarButtonItem* relatedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(relatedButtonClicked:)];
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSMutableArray *barItems = [[NSMutableArray alloc] initWithObjects:flexButton,composeButton,flexButton, editButton, flexButton, deleteButton, flexButton, relatedButton, flexButton, nil];
    [toolbar setItems:barItems];
    [self.navigationController.toolbar addSubview:toolbar];
    [self.navigationController setToolbarHidden:NO];
}

-(IBAction)createButtonClicked:(id)sender
{
    SugarCRMMetadataStore *metadataStore= [SugarCRMMetadataStore sharedInstance];
    EditViewController *editViewController = [EditViewController editViewControllerWithMetadata:[metadataStore objectMetadataForModule:self.metadata.moduleName]];
    editViewController.title = @"Add Record";
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:editViewController];
    navController.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentModalViewController:navController animated:YES];        
}

-(IBAction)deleteButtonClicked:(id)sender
{
    DataObject* dataObject = [detailsArray objectAtIndex:0];
    [dataObject setObject:@"1" forFieldName:@"deleted"];    
    NSArray *uploadData = [NSArray arrayWithObject:dataObject];
    
    SugarCRMMetadataStore *sharedInstance = [SugarCRMMetadataStore sharedInstance];
    DBMetadata *dbMetadata = [sharedInstance dbMetadataForModule:metadata.moduleName];
    DBSession * dbSession = [DBSession sessionWithMetadata:dbMetadata];
    [dbSession insertDataObjectsInDb:uploadData dirty:NO];
    
    SyncHandler * syncHandler = [SyncHandler sharedInstance];
    AppDelegate *sharedAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [sharedAppDelegate showWaitingAlertWithMessage:@"Please wait syncing"];
    [syncHandler uploadData:[NSArray arrayWithObject:[dataObject getNameValueArrayForDelete]] forModule:self.metadata.moduleName parent:self];
    
}

-(IBAction)relatedButtonClicked:(id)sender
{
    // TODO show relationships
    //DUMMY DICNTIONARY,To be replaced by actual data
//    NSMutableDictionary *dataSource = [[NSMutableDictionary alloc] init];
//    NSArray *values = [[NSArray alloc] initWithObjects:@"ROW1",@"ROW2",@"ROW3",@"ROW4", nil];
//    [dataSource setObject:values forKey:@"Contacts"];
//    [dataSource setObject:values forKey:@"Calls"];
//    [dataSource setObject:values forKey:@"Accounts"];
    
    RelationsViewController *relationsController = [[RelationsViewController alloc]initWithDataObject:[detailsArray objectAtIndex:0]];
    relationsController.title = @"Relations";
    [self.navigationController pushViewController:relationsController animated:YES];
}

#pragma mark SyncHandler Delegate

-(void)syncHandler:(SyncHandler*)syncHandler failedWithError:(NSError*)error{
    AppDelegate *sharedAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [sharedAppDelegate dismissWaitingAlert];
    [self performSelectorOnMainThread:@selector(showSyncAlert:) withObject:error waitUntilDone:NO];
}
-(void)syncComplete:(SyncHandler*)syncHandler{
    AppDelegate *sharedAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [sharedAppDelegate dismissWaitingAlert];
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self performSelectorOnMainThread:@selector(showSyncAlert:) withObject:nil waitUntilDone:NO];
}

-(IBAction)showSyncAlert:(id)sender
{
    NSError* error = (NSError*) sender;
    if(error)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Successfully deleted the record" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
        [self.navigationController popViewControllerAnimated:YES];
        // TODO should send a callback to listview to reload records from db
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [datasource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    id<UITableViewCellSectionItem> sectionItem = [datasource objectAtIndex:section];
    return [[sectionItem rowItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<UITableViewCellSectionItem> sectionItem = [datasource objectAtIndex:indexPath.section];
    id<UITableViewCellRowItem> rowItem  = [[sectionItem rowItems] objectAtIndex:indexPath.row];
    return [rowItem reusableCellForTableView:tableView];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<UITableViewCellSectionItem> sectionItem = [datasource objectAtIndex:indexPath.section];
    id<UITableViewCellRowItem> rowItem  = [[sectionItem rowItems] objectAtIndex:indexPath.row];
    return [rowItem heightForCell:(UITableView*)tableView];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id<UITableViewCellSectionItem> sectionItem = [datasource objectAtIndex:section];
    if ([sectionItem sectionTitle] != nil) {
        return [sectionItem sectionTitle];
    }
    return @"";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];   
}

@end
