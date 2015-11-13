//
//  dqxx_model.m
//  cw
//
//  Created by yunlai on 13-9-6.
//
//

#import "dqxx_model.h"
#import "FileManager.h"
#import "FMDatabase.h"

@implementation dqxx_model

- (id)init
{
    self = [super init];
    if (self)
    {
        dbFilePath = [[NSBundle mainBundle]pathForResource:@"dqxx" ofType:@"db"];
        db = [FMDatabase databaseWithPath:dbFilePath];
        tableName = @"DQXX";
        _limit = 0;
    }
	return self;
}

@end
