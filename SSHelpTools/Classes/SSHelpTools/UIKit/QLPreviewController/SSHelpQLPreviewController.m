//
//  SSHelpQLPreviewController.m
//  Pods
//
//  Created by 宋直兵 on 2023/7/24.
//

#import "SSHelpQLPreviewController.h"

@interface SSHelpQLPreviewController ()<QLPreviewControllerDataSource,QLPreviewControllerDelegate>

@end

@implementation SSHelpQLPreviewController

+ (instancetype)ss_new
{
    SSHelpQLPreviewController *vc = [[[self class] alloc] init];
    vc.dataSource = vc;
    vc.delegate = vc;
    return vc;
}

#pragma mark -
#pragma mark - QLPreviewControllerDataSource Method

/*!
 * @abstract Returns the number of items that the preview controller should preview.
 * @param controller The Preview Controller.
 * @result The number of items.
 */
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

/*!
 * @abstract Returns the item that the preview controller should preview.
 * @param controller The Preview Controller.
 * @param index The index of the item to preview.
 * @result An item conforming to the QLPreviewItem protocol.
 */
- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return self.fileURL;
}

@end
