//
//  DBModel.m
//  cw
//
//  Created by siphp on 13-8-12
//

#import "db_model.h"
#import "FileManager.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@implementation db_model

@synthesize where = _where;
@synthesize orderBy = _orderBy;
@synthesize orderType = _orderType;
@synthesize limit = _limit;

/*
+ (void)initialize {
    NSLog(@"----------");
}
*/

- (id)init
{
    self = [super init];
    if (self)
    {
        dbFilePath=[FileManager getFileDBPath:dataBaseFile];
        db=[FMDatabase databaseWithPath:dbFilePath];
        tableName = [[NSString stringWithFormat:@"t_%@",[self class]] stringByReplacingOccurrencesOfString:@"_model" withString:@""];
        _limit = 0;
    }
	return self;
}

//获取列表 支持条件 条数 排序
-(NSMutableArray *)getList
{
	if ([db open])
    {
		[db setShouldCacheStatements:YES];
		NSMutableArray *FinalArray=[NSMutableArray arrayWithCapacity:0];
		FMResultSet *rs = nil;
        
        NSMutableString *sql = [NSMutableString stringWithString:[NSString stringWithFormat:@"select * from %@ where 1",tableName]];

        //条件
        if (_where != nil && ![_where isEqual:@""])
        {
            [sql appendFormat:@" and %@",_where];
        }
        
        //排序
        if (_orderBy != nil && ![_orderBy isEqual:@""])
        {
            _orderType = (_orderType != nil && ![_orderType isEqual:@""]) ? _orderType : @"asc";
            [sql appendFormat:@" order by %@ %@",_orderBy,_orderType];
        }

        //条数
        if (_limit != 0)
        {
            [sql appendFormat:@" limit 0 , %d",_limit];
        }

		rs=[db executeQuery:sql];
		
		int col = sqlite3_column_count(rs.statement.statement);
		while ([rs next])
        {
            NSMutableDictionary *rsDic = [NSMutableDictionary dictionaryWithCapacity:col];
			for (int i=0; i<col; i++)
            {
				NSString *key =[rs columnNameForIndex:i];
                NSString *value = [rs stringForColumnIndex:i];
                
				if (value == nil)
                {
					[rsDic setObject:@"" forKey:key];
				}
				else
                {
					[rsDic setObject:value forKey:key];
				}
			}
            
			[FinalArray addObject:rsDic];
		}
		[rs close];
		[db close];
		return FinalArray;
	}
    else
    {
		NSLog(@"could not open dababase!");
		return nil;
	}
}

//插入数据 成功则返回插入ID 失败则返回 0
-(int)insertDB:(NSDictionary *)data
{
    if ([data count] > 0)
    {
        if ([db open])
        {
            NSMutableString *sql = [NSMutableString stringWithString:[NSString stringWithFormat:@"insert into %@",tableName]];
            
            NSString *fieldString = [[data allKeys] componentsJoinedByString:@","];
            NSString *valuesString = [[data allValues] componentsJoinedByString:@"','"];
            [sql appendFormat:@" (%@) values ('%@')",fieldString,valuesString];

            [db setShouldCacheStatements:YES];
            [db beginTransaction];
            [db executeUpdate:sql];
            if ([db hadError])
            {
                NSLog(@"Err %d %@",[db lastErrorCode],[db lastErrorMessage]);
                [db rollback];
                [db close];
                return 0;
            }
            else
            {
                [db commit];
                int insertId = [db lastInsertRowId];
                [db close];
                return insertId;
            }
        }
        else
        {
            NSLog(@"could not open dababase!");
            return 0;
        }
    }
    else
    {
        return 0;
    }
}

//更新记录 支持条件更新
-(BOOL)updateDB:(NSDictionary *)data;
{
    if ([data count] > 0)
    {
        if ([db open])
        {
            NSMutableString *sql = [NSMutableString stringWithString:[NSString stringWithFormat:@"update %@",tableName]];
            
            NSMutableArray *setValueArray = [NSMutableArray arrayWithCapacity:0];
            for (id key in [data allKeys])
            {
                [setValueArray addObject:[NSString stringWithFormat:@"%@ = '%@'",key,[data objectForKey:key]]];
            }
            NSString *setValuesString = [setValueArray componentsJoinedByString:@" , "];
            [sql appendFormat:@" set %@ where 1",setValuesString];
            
            //条件
            if (_where != nil && ![_where isEqual:@""])
            {
                [sql appendFormat:@" and %@",_where];
            }

            [db setShouldCacheStatements:YES];
            [db beginTransaction];
            [db executeUpdate:sql];
            if ([db hadError])
            {
                NSLog(@"Err %d %@",[db lastErrorCode],[db lastErrorMessage]);
                [db rollback];
                [db close];
                return NO;
            }
            else
            {
                [db commit];
                [db close];
                return YES;
            }
        }
        else
        {
            NSLog(@"could not open dababase!");
            return NO;
        }
    }
    else
    {
        return NO;
    }
}

//删除记录 支持条件更新
-(BOOL)deleteDBdata
{
    if ([db open])
    {
        NSMutableString *sql = [NSMutableString stringWithString:[NSString stringWithFormat:@"delete from %@ where 1",tableName]];
        
        //条件
        if (_where != nil && ![_where isEqual:@""])
        {
            [sql appendFormat:@" and %@",_where];
        }

        [db setShouldCacheStatements:YES];
        [db beginTransaction];
        [db executeUpdate:sql];
        if ([db hadError])
        {
            NSLog(@"Err %d %@",[db lastErrorCode],[db lastErrorMessage]);
            [db rollback];
            [db close];
            return NO;
        }
        else
        {
            [db commit];
            [db close];
            return YES;
        }
    }
    else
    {
        NSLog(@"could not open dababase!");
        return NO;
    }
}

//执行sql语句 用于查询
-(NSMutableArray *)querSelectSql:(NSString *)sql
{
    if ([db open])
    {
		[db setShouldCacheStatements:YES];
		NSMutableArray *FinalArray=[NSMutableArray arrayWithCapacity:0];
		FMResultSet *rs = nil;
        
		rs=[db executeQuery:sql];
		
		int col = sqlite3_column_count(rs.statement.statement);
		while ([rs next])
        {
            NSMutableDictionary *rsDic = [NSMutableDictionary dictionaryWithCapacity:col];
			for (int i=0; i<col; i++)
            {
				NSString *key =[rs columnNameForIndex:i];
                NSString *value = [rs stringForColumnIndex:i];
                
				if (value == nil)
                {
					[rsDic setObject:@"" forKey:key];
				}
				else
                {
					[rsDic setObject:value forKey:key];
				}
			}
            
			[FinalArray addObject:rsDic];
		}
		[rs close];
		[db close];
		return FinalArray;
	}
    else
    {
		NSLog(@"could not open dababase!");
		return nil;
	}
}

//执行sql语句 用于更新 删除
-(BOOL)queryUpdateSql:(NSString *)sql
{
	db=[FMDatabase databaseWithPath:dbFilePath];
	if ([db open])
    {
		[db setShouldCacheStatements:YES];
		[db beginTransaction];
		[db executeUpdate:sql];
		if ([db hadError])
        {
			NSLog(@"Err %d %@",[db lastErrorCode],[db lastErrorMessage]);
			[db rollback];
            [db close];
			return NO;
		}
		[db commit];
		[db close];
		return YES;
	}
    else
    {
		NSLog(@"could not open dababase!");
		return NO;
	}
}


- (void)dealloc
{
    [_where release];
    [_orderBy release];
    [_orderType release];
    [super dealloc];
}

@end
