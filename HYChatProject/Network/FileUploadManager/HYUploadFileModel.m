//
//  HYUploadFileModel.m
//  HYChatProject
//
//  Created by erpapa on 16/5/12.
//  Copyright © 2016年 erpapa. All rights reserved.
//

#import "HYUploadFileModel.h"

@implementation HYUploadFileModel

- (id)init
{
    if (self = [super init]) {
        
        /* 默认上传原始图片 */
        self.isUploadAssetOriginImage = YES;
        
        /* 默认上传图片的时候是没被归档的 */
        self.isUploadImageHasBeenArchieved = NO;
    }
    return self;
}
/* 便捷对象生成 */
+ (HYUploadFileModel*)fileModelWithFileName:(NSString*)fileName withFilePath:(NSString*)filePath withFormName:(NSString*)formName
{
    return [HYUploadFileModel fileModelWithFileName:fileName withFilePath:filePath withFormName:formName withMimeType:nil];
}

/* 便捷对象生成 */
+ (HYUploadFileModel*)fileModelWithFileName:(NSString*)fileName withFilePath:(NSString*)filePath withFormName:(NSString*)formName withMimeType:(NSString*)mimeType
{
    HYUploadFileModel *fileModel = [[self alloc]init];
    fileModel.fileName = fileName;
    fileModel.localStorePath = filePath;
    fileModel.formName = formName;
    if (!mimeType) {
        fileModel.mimeType = [HYUploadFileModel mimeTypeWithFileName:fileName];
    }else{
        fileModel.mimeType = mimeType;
    }
    
    return fileModel;
}

+ (HYUploadFileModel*)fileModelWithFileName:(NSString*)fileName withFileData:(NSData*)fileData withFormName:(NSString*)formName
{
    return [HYUploadFileModel fileModelWithFileName:fileName withFileData:fileData withFormName:formName withMimeType:@"application/octet-stream"];
}

+ (HYUploadFileModel*)fileModelWithFileName:(NSString*)fileName withFileData:(NSData*)fileData withFormName:(NSString*)formName withMimeType:(NSString*)mimeType
{
    HYUploadFileModel *fileModel = [[self alloc]init];
    fileModel.fileName = fileName;
    fileModel.fileData = fileData;
    fileModel.formName = formName;
    if (!mimeType) {
        fileModel.mimeType = [HYUploadFileModel mimeTypeWithFileName:fileName];
    }else{
        fileModel.mimeType = mimeType;
    }
    
    return fileModel;
}

+ (NSString*)mimeTypeWithFileName:(NSString*)fileName
{
    NSString *fileExtension = [[fileName componentsSeparatedByString:@"."]lastObject];
    NSLog(@"fileExtension:%@",fileExtension);
    if (!fileExtension) {
        return nil;
    }
    
    NSDictionary *typeMapDict = @{
                                  @"png": @"image/png",
                                  
                                  @"PNG": @"image/png",
                                  
                                  @"jpg": @"image/jpeg",
                                  
                                  @"JPG": @"image/jpeg",
                                  
                                  @"jpeg": @"image/jpeg",

                                  @"JPEG": @"image/jpeg",
                                  
                                  @"GIF": @"image/jpeg",
                                  
                                  @"gif": @"image/jpeg",

                                  @"mp3": @"audio/mp3",
                                  
                                  @"MP3": @"audio/mp3",
                                  
                                  @"amr": @"application/octet-stream",
                                  
                                  @"AMR": @"application/octet-stream",
                                  
                                  @"mov": @"application/octet-stream",
                                  };
    
    return [typeMapDict objectForKey:fileExtension];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"文件名:%@ 文件类型:%@ 表单名字:%@",self.fileName,self.mimeType,self.formName];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
        self.fileName = [aDecoder decodeObjectForKey:@"fileName"];
        
        self.fileData = [aDecoder decodeObjectForKey:@"fileData"];
        
        self.mimeType = [aDecoder decodeObjectForKey:@"mimeType"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.fileName forKey:@"fileName"];
    
    [aCoder encodeObject:self.fileData forKey:@"fileData"];

    [aCoder encodeObject:self.mimeType forKey:@"mimeType"];

}

/* 自身检测是否符合上传规则 */
- (BOOL)isValidateForUpload
{
    /* 直接上传文件二进制数据 */
    if (self.fileData) {
        
        if (!self.fileName || !self.mimeType || !self.formName) {
            
            NSLog(@"待上传的二进制文件不合法:  文件名:%@,MIME:%@,表单名:%@",self.fileName,self.mimeType,self.formName);

            return NO;
        }
        return YES;
        
    }else{
        
        /* 语音或者图片 */
        if (self.isUploadAudio || self.isUploadImage) {
            
            if (!self.fileName || !self.mimeType || !self.formName || !self.localStorePath) {
                
                NSLog(@"待上传的音频或者图片不合法:  文件名:%@,MIME:%@,表单名:%@,本地文件路径:%@",self.fileName,self.mimeType,self.formName,self.localStorePath);
                
                return NO;
            }
            
            return YES;
        }
        
        /* asset文件 */
        if (self.isUploadAsset) {
            
            if (!self.fileName || !self.mimeType || !self.formName || !self.contentAsset) {
                
                NSLog(@"待上传的Asset文件不合法:  文件名:%@,MIME:%@,表单名:%@,Assets文件:%@",self.fileName,self.mimeType,self.formName,self.contentAsset);

                return NO;
            }
            
            return YES;
        }
        
        /* 都不是上面的类型 */
        if (!self.fileName || !self.mimeType || !self.formName || !self.localStorePath) {
            
            NSLog(@"待上传的本地路径文件不合法:  文件名:%@,MIME:%@,表单名:%@,本地路径:%@",self.fileName,self.mimeType,self.formName,self.localStorePath);
            
            return NO;
        }
        
        return YES;
    }
    
}

@end
