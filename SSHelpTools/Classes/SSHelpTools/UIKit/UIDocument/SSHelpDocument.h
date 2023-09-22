//
//  SSHelpDocument.h
//  Pods
//
//  Created by 宋直兵 on 2023/8/11.
//

#import <UIKit/UIKit.h>
#import "SSHelpDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpDocument : UIDocument

@property(nonatomic, strong, nullable) id response;

@end



@interface SSHelpDocumentManager : NSObject

+ (instancetype)shared;

@property(nonatomic, strong, nullable) NSURL *documentsURL;

@property(nonatomic, strong) NSString *ubiquityContainerIdentifier;

- (void)saveFileURL:(NSURL *)fileURL callback:(SSBlockCallback)callback;

- (void)saveFileURL:(NSURL *)fileURL toURL:(NSURL *)toURL progress:(SSBlockId)progress callback:(SSBlockCallback)callback;


- (void)readFile:(NSString *)fileName callback:(SSBlockCallback)callback;

- (void)readFileURL:(NSURL *)fileURL callback:(SSBlockCallback)callback;


@end

NS_ASSUME_NONNULL_END
