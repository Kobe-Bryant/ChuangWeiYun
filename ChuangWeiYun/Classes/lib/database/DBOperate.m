//
//  DBOperate.m
//  Shopping
//
//  Created by zhu zhu chao on 11-3-22.
//  Copyright 2011 sal. All rights reserved.
//

#import "DBOperate.h"
#import "FileManager.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "DBConfig.h"

@implementation DBOperate

//创建表
+(BOOL)createTable
{
    //获取所有的表字典
    NSDictionary *tableDic = [DBConfig getDbTablesDic];
    
	NSString *dbFilePath=[FileManager getFileDBPath:dataBaseFile];
	NSLog(@"dbFilePath:---------------- %@",dbFilePath);
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
	if ([db open]) {
		[db setShouldCacheStatements:YES];
		for (id key in [tableDic allKeys])
        {
			NSString *checkTableSQL = [NSString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@'",key];
			FMResultSet *rs = [db executeQuery:checkTableSQL];
			if (![rs next]) {
				[db executeUpdate:[tableDic objectForKey:key]];
			}
		}
		
	}
	[db close];
	return YES;
}

@end
