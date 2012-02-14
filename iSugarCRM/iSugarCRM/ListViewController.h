//
//  ListViewController.h
//  iSugarCRM
//
//  Created by Ved Surtani on 06/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListViewMetadata.h"
#import "DBSession.h"
@interface ListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,DBLoadSessionDelegate, UISearchBarDelegate>
{
    @private
    UITableView *myTableView;
    UISearchBar *sBar;
}

+(ListViewController*)listViewControllerWithMetadata:(ListViewMetadata*)metadata;
+(ListViewController*)listViewControllerWithModuleName:(NSString*)module;
@property(strong)NSString *moduleName;
@property(strong)NSArray *datasource;
@property(strong) NSMutableArray *tableData;
@property(strong)ListViewMetadata *metadata;
@end
