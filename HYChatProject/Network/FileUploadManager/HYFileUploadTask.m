//
//  HYFileUploadTask.m
//  HYChatProject
//
//  Created by erpapa on 16/5/12.
//  Copyright © 2016年 erpapa. All rights reserved.
//

#import "HYFileUploadTask.h"
#import "HYUploadFileModel.h"
#import "HYFileUploadManager.h"

@interface HYFileUploadTask()

@property (nonatomic,strong)NSString *innerIdentifier;

@property (nonatomic,strong)NSMutableArray *innerTaskObserverArray;

@end

@implementation HYFileUploadTask

/*
 * 使用待上传文件组的路径来上传这些文件
 */
+ (HYFileUploadTask *)taskWithUploadFilePaths:(NSArray *)filePaths usingCommonExtension:(BOOL)isCommmonExtentsion commonExtension:(NSString *)commonExtension withFormName:(NSString *)formName taskObserver:(NSObject*)observer getTaskUniqueIdentifier:(NSString**)taskIdentifier
{
    if (!filePaths || filePaths.count == 0 || !formName ) {
        return nil;
    }
    
    NSMutableArray *modelArray = [NSMutableArray array];
    
    for(NSString *fileItemPath in filePaths){
        
        NSString *fileName = [fileItemPath lastPathComponent];
        NSString *fileExtention = nil;
        
        /* 路径中的文件有没有扩展名 */
        if ([fileName componentsSeparatedByString:@"."].count > 0) {
            fileExtention = [[fileName componentsSeparatedByString:@"."]lastObject];
        }
        
        /* 如果文件组使用统一的扩展名 */
        if (isCommmonExtentsion) {
            fileExtention = commonExtension;
        }
        
        /* 如果这里扩展名还为空，那么肯定不能上传了  */
        if (fileExtention == nil) {
            NSLog(@"fileItemPath:%@ 没有文件扩展名，无法添加到任务中，无法生成上传文件组的任务",fileItemPath);
            break;
            return nil;
        }
        
        /* 组成新的文件名 */
        fileName = [NSString stringWithFormat:@"%@.%@",[[fileName componentsSeparatedByString:@"."]firstObject],fileExtention];
        HYUploadFileModel *aFile = [HYUploadFileModel fileModelWithFileName:fileName withFilePath:fileItemPath withFormName:formName];
        
        [modelArray addObject:aFile];

    }

    return [HYFileUploadTask taskWithMutilFile:modelArray taskObserver:observer getTaskUniqueIdentifier:taskIdentifier];
}

/*
 * 指定特殊这个任务特殊的观察者情况下: 单个文件上传任务便捷生成
 */
+ (HYFileUploadTask *)taskWithFilePath:(NSString*)filePath withFileName:(NSString*)fileName withFormName:(NSString*)formName taskObserver:(NSObject*)observer getTaskUniqueIdentifier:(NSString**)taskIdentifier
{
    if (!filePath || !formName ) {
        return nil;
    }
    
    NSString *filePathFileName = [filePath lastPathComponent];
    NSString *fileExtension = nil;
    
    /* 如果文件路径已经有扩展名，那么就直接读取文件路径的扩展名,如果没有从fileName里面读，如果都没有扩展名，那么就返回空任务，不能往下执行任务 */
    if ([filePathFileName componentsSeparatedByString:@"."].count > 0) {
        
        fileExtension = [[filePathFileName componentsSeparatedByString:@"."]lastObject];
        
    }else{
        
        if (!fileExtension) {
            
            if (fileName) {
                if ([fileName componentsSeparatedByString:@"."].count > 0) {
                    
                    NSString *fileNameExtension = [[fileName componentsSeparatedByString:@"."]lastObject];
                    
                    if (!fileExtension) {
                        
                        fileExtension = fileNameExtension;
                        filePath = [NSString stringWithFormat:@"%@.%@",filePath,fileExtension];
                        
                    }else{
                        
                        /* 都没有扩展名就不能继续任务，因为无法找到MIMETYPE */
                        return nil;
                    }
                }
            }
            
        }
        
    }
    
    
    return [HYFileUploadTask taskWithUploadFilePaths:@[filePath] usingCommonExtension:NO commonExtension:nil withFormName:formName taskObserver:observer getTaskUniqueIdentifier:taskIdentifier];
}

+ (HYFileUploadTask *)taskWithFileData:(NSData *)fileData withFileName:(NSString *)fileName  withFormName:(NSString*)formName taskObserver:(NSObject*)observer getTaskUniqueIdentifier:(NSString *__autoreleasing *)taskIdentifier
{
    if (!fileData || !fileName) {
        return nil;
    }
    
    HYUploadFileModel *aFileModel = [HYUploadFileModel fileModelWithFileName:fileName withFileData:fileData withFormName:formName];
    
    return [HYFileUploadTask taskForFile:aFileModel taskObserver:observer getTaskUniqueIdentifier:taskIdentifier];
}

+ (HYFileUploadTask *)taskForFile:(HYUploadFileModel *)aFile taskObserver:(NSObject*)observer getTaskUniqueIdentifier:(NSString *__autoreleasing *)taskIdentifier
{
    if (!aFile) {
        return nil;
    }
    
    return [HYFileUploadTask taskWithMutilFile:[@[aFile] mutableCopy] taskObserver:observer getTaskUniqueIdentifier:taskIdentifier];
}

+ (HYFileUploadTask *)taskWithMutilFile:(NSArray *)fileModelArray taskObserver:(NSObject*)observer getTaskUniqueIdentifier:(NSString *__autoreleasing *)taskIdentifier
{
    if (!fileModelArray || fileModelArray.count == 0) {
        return nil;
    }
    
    HYFileUploadTask *task = [[self alloc]init];
    [task.filesArray addObjectsFromArray:fileModelArray];
    *taskIdentifier = task.uniqueIdentifier;
    [task addNewTaskObserver:observer];
    
    return task;
    
}

+ (HYFileUploadTask *)taskWithUploadImages:(NSArray *)imagesArray commonExtension:(NSString*)extention  withFormName:(NSString*)formName taskObserver:(NSObject*)observer getTaskUniqueIdentifier:(NSString**)taskIdentifier
{
    
    NSMutableArray *modelArray = [NSMutableArray array];
    
    [imagesArray enumerateObjectsUsingBlock:^(UIImage *aImage, NSUInteger idx, BOOL *stop) {
        
        NSString *fileName = [NSString stringWithFormat:@"%@.%@",[HYFileUploadTask currentTimeStamp],extention];
        NSData *fileData = nil;
        if ([extention isEqualToString:@"png"] || [extention isEqualToString:@"PNG"] ) {
            
            fileData = UIImagePNGRepresentation(aImage);
        }
        if ([extention isEqualToString:@"jpg"] || [extention isEqualToString:@"jpeg"] || [extention isEqualToString:@"JPG"] || [extention isEqualToString:@"JPEG"]) {
            
            fileData = UIImageJPEGRepresentation(aImage, 0.5);
        }
        HYUploadFileModel *aFile = [HYUploadFileModel fileModelWithFileName:fileName withFileData:fileData withFormName:formName];
        [modelArray addObject:aFile];
        
    }];
    
    return [HYFileUploadTask taskWithMutilFile:modelArray taskObserver:observer getTaskUniqueIdentifier:taskIdentifier];
}

/* 默认由UploadManager指定观察者情况下: 相同属性，无文件名的图片便捷任务生成 */
+ (HYFileUploadTask *)taskWithUploadImages:(NSArray *)imagesArray commonExtension:(NSString*)extention withFormName:(NSString*)formName getTaskUniqueIdentifier:(NSString**)taskIdentifier
{
   return [HYFileUploadTask taskWithUploadImages:imagesArray commonExtension:extention withFormName:formName taskObserver:nil getTaskUniqueIdentifier:taskIdentifier];
}

/* 默认由UploadManager指定观察者情况下: 单个文件上传任务便捷生成 */
+ (HYFileUploadTask *)taskWithFileData:(NSData*)fileData withFileName:(NSString*)fileName withFormName:(NSString*)formName getTaskUniqueIdentifier:(NSString**)taskIdentifier
{
    return [HYFileUploadTask taskWithFileData:fileData withFileName:fileName withFormName:formName taskObserver:nil getTaskUniqueIdentifier:taskIdentifier];
}

/* 默认由UploadManager指定观察者情况下: 文件组上传任务 */
+ (HYFileUploadTask *)taskWithMutilFile:(NSArray*)fileModelArray getTaskUniqueIdentifier:(NSString**)taskIdentifier
{
    return [HYFileUploadTask taskWithMutilFile:fileModelArray taskObserver:nil getTaskUniqueIdentifier:taskIdentifier];
}

/* 默认由UploadManager指定观察者情况下: 单个文件上传任务 */
+ (HYFileUploadTask *)taskForFile:(HYUploadFileModel*)aFile getTaskUniqueIdentifier:(NSString *__autoreleasing *)taskIdentifier
{
    return [HYFileUploadTask taskForFile:aFile taskObserver:nil getTaskUniqueIdentifier:taskIdentifier];
}

- (id)init
{
    if (self = [super init]) {
        
        self.filesArray = [[NSMutableArray alloc]init];
        self.innerTaskObserverArray = [[NSMutableArray alloc]init];
        self.uploadState = GJFileUploadStateNeverBegin;
        
    }
    return self;
}

- (NSString *)uniqueIdentifier
{
    if (self.innerIdentifier) {
        return self.innerIdentifier;
    }
    
    self.innerIdentifier = [HYFileUploadTask currentTimeStamp];
    return self.innerIdentifier;
}

- (NSArray*)taskObservers
{
    return self.innerTaskObserverArray;
}

+ (NSString *)currentTimeStamp
{
    NSDate *now = [NSDate date];
    NSTimeInterval timeInterval = [now timeIntervalSinceReferenceDate];
    
    NSString *timeString = [NSString stringWithFormat:@"%lf",timeInterval];
    timeString = [timeString stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    
    return timeString;
}

- (BOOL)isEqual:(HYFileUploadTask *)aTask
{
    if (!aTask || ![aTask isKindOfClass:[HYFileUploadTask class]]) {
        return NO;
    }
    return [self.uniqueIdentifier isEqualToString:aTask.uniqueIdentifier];
}

#pragma mark - NSCoding 

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
        self.uploadState = [aDecoder decodeIntegerForKey:@"uploadState"];
        
        self.innerIdentifier  = [aDecoder decodeObjectForKey:@"innerIdentifier"];
        
        self.customRequestHeader = [aDecoder decodeObjectForKey:@"customRequestHeader"];
        
        self.customRequestParams = [aDecoder decodeObjectForKey:@"customRequestParams"];
        
        self.filesArray = [aDecoder decodeObjectForKey:@"filesArray"];
        
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.uploadState forKey:@"uploadState"];
    
    [aCoder encodeObject:self.innerIdentifier forKey:@"innerIdentifier"];
    
    [aCoder encodeObject:self.customRequestHeader forKey:@"customRequestHeader"];
    
    [aCoder encodeObject:self.customRequestParams forKey:@"customRequestParams"];
    
    [aCoder encodeObject:self.filesArray forKey:@"filesArray"];
}

#pragma mark - 观察者添加、移除操作
/* 单任务多观察者添加 */
- (void)addNewTaskObserver:(id)observer
{
    if (!observer) {
        return;
    }
    
    NSString *uniqueIdentifier = [HYFileUploadManager uniqueKeyForObserver:observer];
    
    if ([self.innerTaskObserverArray containsObject:uniqueIdentifier]) {
        
        return;
    }
    
    [self.innerTaskObserverArray addObject:uniqueIdentifier];
}

/* 移除任务观察者 */
- (void)removeTaskObserver:(id)observer
{
    if (!observer) {
        return;
    }
    
    NSString *uniqueIdentifier = [HYFileUploadManager uniqueKeyForObserver:observer];
    
    if (![self.innerTaskObserverArray containsObject:uniqueIdentifier]) {
        
        return;
    }
    
    [self.innerTaskObserverArray removeObject:uniqueIdentifier];
}

/* 移除所有任务观察者 */
- (void)removeAllTaskObserver
{
    if (self.innerTaskObserverArray && self.innerTaskObserverArray.count > 0) {
        
        [self.innerTaskObserverArray removeAllObjects];
    }
}

/* 单任务多观察者添加观察者唯一标示 */
- (void)addNewTaskObserverUniqueIdentifier:(NSString*)uniqueId
{
    if (!uniqueId) {
        return;
    }
    
    if ([self.innerTaskObserverArray containsObject:uniqueId]) {
        
        return;
    }
    
    [self.innerTaskObserverArray addObject:uniqueId];
    
}

/* 单任务多观察移除加观察者唯一标示 */
- (void)removeTaskObserverUniqueIdentifier:(NSString*)uniqueId
{
    if (!uniqueId) {
        return;
    }
    
    if (![self.innerTaskObserverArray containsObject:uniqueId]) {
        
        return;
    }
    
    [self.innerTaskObserverArray removeObject:uniqueId];
}

/* 判断某个观察者Id是否存在 */
- (BOOL)taskIsObservedByUniqueIdentifier:(NSString*)uniqueId
{
    if (!uniqueId) {
        
        return NO;
    }
    
    return [self.innerTaskObserverArray containsObject:uniqueId];
}

/*
 * 该任务是否符合上传条件
 */
- (BOOL)isValidateBeingForUpload
{
    __block BOOL isValidate = YES;
    [self.filesArray enumerateObjectsUsingBlock:^(HYUploadFileModel *aFile, NSUInteger idx, BOOL *stop) {
        
        if (![aFile isValidateForUpload]) {
            
            isValidate = NO;
            
            *stop = YES;
        }
    }];
    
    return isValidate;
}

@end
