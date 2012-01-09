//
//  DetailViewMetadata.m
//  iSugarCRM
//
//  Created by Ved Surtani on 06/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewMetadata.h"
#import "DetailViewSectionItem.h"
#import "DataObjectField.h"
@implementation DetailViewMetadata
@synthesize objectMetadata,moduleName,sectionItems;
-(NSDictionary*)toDictionary
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:moduleName forKey:@"module_name"];
    [dictionary setObject:[objectMetadata toDictionary] forKey:@"objectMetadata"];
    
    NSMutableArray *sections = [NSMutableArray array];
    for(NSString *key in [sectionItems allKeys])
    {
        NSMutableArray *sectionRowitems =[NSMutableArray array];
        for (DataObjectField *rowItem in [sectionItems objectForKey:key])
        {
            [sectionRowitems addObject:[rowItem toDictionary]];
        }
        NSMutableDictionary *sectionDictionary = [NSMutableDictionary dictionary];
        [sectionDictionary setObject:sectionRowitems forKey:@"rowItems"];
        [sectionDictionary setObject:key forKey:@"section_name"];
        [sections addObject:sectionDictionary];
    }
    [dictionary setObject:sections forKey:@"sectionItems"];
    return dictionary;
    
}
+(DetailViewMetadata*)objectFromDictionary:(NSDictionary *)dictionary
{
    DetailViewMetadata *detailViewMetadata = [[DetailViewMetadata alloc] init];
    NSMutableDictionary *sectionItems = [[NSMutableDictionary alloc] init];
    NSMutableArray *sections = [dictionary objectForKey:@"sectionItems"];
    for(NSDictionary *section in sections)
    {
        NSString *key = [section objectForKey:@"section_name"];
        NSArray *rowItems = [section objectForKey:@"rowItems"];
        NSMutableArray *sectionRowItems = [[NSMutableArray alloc] init];
        for(NSDictionary *rowItem in rowItems)
        {
            [sectionRowItems addObject:[DataObjectField objectFromDictionary:rowItem]];
        }
        [sectionItems setObject:sectionRowItems forKey:key];
    }    
    detailViewMetadata.sectionItems = sectionItems;
    detailViewMetadata.moduleName = [dictionary objectForKey:@"module_name"];
    detailViewMetadata.objectMetadata = [DataObjectMetadata objectFromDictionary:[dictionary objectForKey:@"objectMetadata"]];
    return detailViewMetadata ;
}

-(id)copy
{
    DetailViewMetadata *copy = [[DetailViewMetadata alloc] init];
    copy.sectionItems = sectionItems;
    copy.objectMetadata = objectMetadata;
    copy.moduleName = moduleName;
    return copy;
}

@end