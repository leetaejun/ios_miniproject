
#import "DBManager.h"
#import <sqlite3.h>

@interface DBManager()

@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *databaseFilename;
@property (nonatomic, strong) NSMutableArray *arrResults;

- (void)copyDatabaseIntoDocumentsDirectory;
- (void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable;

@end

@implementation DBManager

/*!
 @brief     파일이름으로 데이터베이스 초기화하기
 @param
  - dbFilename : 데이터베이스 파일명
 @return
  - 클래스 인스턴스
 @remark
 @author    이태준
 **/
- (instancetype)initWithDatabaseFilename:(NSString *)dbFilename {
    self = [super init];
    if (self) {
        // DocumentDirectory로 경로를 설정
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [paths objectAtIndex:0];
        
        // filename 유지
        self.databaseFilename = dbFilename;
        
        [self copyDatabaseIntoDocumentsDirectory];
    }
    return self;
}



/*!
 @brief     인스턴스를 Documents 디렉토리에 있는 데이터베이스 파일로 복사하기
 @param
 @return
 @remark
 @author    이태준
 **/
- (void)copyDatabaseIntoDocumentsDirectory {
    // document directory 안에 database 파일 존재를 체크하기 위해
    NSString *destinationPath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseFilename];
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}


/*!
 @brief     인스턴스를 통해 질의를 수행하여 결과를 생성
 @param
  - query : 질의
  - queryExecutable : Executable 질의인지 여부(INSERT, UPDATE, ...)
 @return
 @remark
 @author    이태준
 **/
- (void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable {
    // SQLite3 객체 생성
    sqlite3 *sqlite3Database;
    
    // 경로 설정
    NSString *databasePath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    
    // 결과 배열 초기화
    if (self.arrResults != nil) {
        [self.arrResults removeAllObjects];
        self.arrResults = nil;
    }
    self.arrResults = [[NSMutableArray alloc] init];
    
    // 컬럼이름 배열 초기화
    if (self.arrColumnNames != nil) {
        [self.arrColumnNames removeAllObjects];
        self.arrColumnNames = nil;
    }
    self.arrColumnNames = [[NSMutableArray alloc] init];
    
    
    // SQLite 열기
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    if(openDatabaseResult == SQLITE_OK) {
        // 컴파일 된 statement 생성
        sqlite3_stmt *compiledStatement;
        
        // 데이터 로드
        BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL);
        if(prepareStatementResult == SQLITE_OK) {
            // Excutable 체크
            if (!queryExecutable) {
                // 이 곳에서는 데이터 로드
                
                // fetch 결과를 유지하기 위한 배열 선언
                NSMutableArray *arrDataRow;
                
                // 결과 값을 만들기 위한 반복문
                while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                    arrDataRow = [[NSMutableArray alloc] init];
                    
                    int totalColumns = sqlite3_column_count(compiledStatement);
                    
                    for (int i=0; i<totalColumns; i++) {
                        char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
                        
                        if (dbDataAsChars != NULL) {
                            [arrDataRow addObject:[NSString  stringWithUTF8String:dbDataAsChars]];
                        }
                        
                        if (self.arrColumnNames.count != totalColumns) {
                            dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
                            [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                    }
                    
                    if (arrDataRow.count > 0) {
                        [self.arrResults addObject:arrDataRow];
                    }
                }
            }
            else {
                // (insert, update, ...).
                
                // 쿼리 실행
                BOOL executeQueryResults = sqlite3_step(compiledStatement);
                if (executeQueryResults) {
                    self.affectedRows = sqlite3_changes(sqlite3Database);
                    
                    self.lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
                }
                else {
                    NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
                }
            }
        }
        else {
            NSLog(@"%s", sqlite3_errmsg(sqlite3Database));
        }
        
        // 컴파일 statement를 메모리에서 릴리즈
        sqlite3_finalize(compiledStatement);
        
    }
    
    // SQLite3 닫기
    sqlite3_close(sqlite3Database);
}

#pragma mark - Public method implementation
/*!
 @brief     데이터베이스로부터 질의를 통해 데이터 얻기
 @param
  - query : 질의
 @return
  - NSArray : 수행된 질의에 대한 결과
 @remark
 @author    이태준
 **/
- (NSArray *)loadDataFromDB:(NSString *)query {
    [self runQuery:[query UTF8String] isQueryExecutable:NO];
    
    return (NSArray *)self.arrResults;
}

/*!
 @brief     데이터베이스에 질의 수행시키기
 @param
  - query : 질의
 @return
 @remark
 @author    이태준
 **/
- (void)executeQuery:(NSString *)query {
    [self runQuery:[query UTF8String] isQueryExecutable:YES];
}

@end
