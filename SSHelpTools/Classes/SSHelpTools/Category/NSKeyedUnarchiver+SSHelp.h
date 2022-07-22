//
//  NSKeyedUnarchiver+SSHelp.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSKeyedUnarchiver (SSHelp)

+ (NSData *)ss_archivedDataWithRootObject:(id)rootObject;

+ (nullable id)ss_unarchiveObjectWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
