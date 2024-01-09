//
//  SSHelpListLayoutAttributes.m
//  Pods
//
//  Created by 宋直兵 on 2024/1/2.
//

#import "SSHelpListLayoutAttributes.h"

NSString *const _kSSListElementKindSectionHeader = @"_kSSListElementKindSectionHeader";
NSString *const _kSSListElementKindSectionFooter = @"_kSSListElementKindSectionFooter";
NSString *const _kSSListElementKindSectionBack   = @"_kSSListElementKindSectionBack";

@implementation SSHelpListLayoutAttributes

+ (instancetype)ss_headerWithSection:(NSInteger)section
{
    NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:section];
    SSHelpListLayoutAttributes *attribute;
    attribute = [self layoutAttributesForSupplementaryViewOfKind:_kSSListElementKindSectionHeader withIndexPath:path];
    return attribute;
}

+ (instancetype)ss_cellForItem:(NSInteger)idx inSection:(NSInteger)section
{
    NSIndexPath *path = [NSIndexPath indexPathForItem:idx inSection:section];
    SSHelpListLayoutAttributes *attribute = [self layoutAttributesForCellWithIndexPath:path];
    return attribute;
}

+ (instancetype)ss_footerWithSection:(NSInteger)section
{
    NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:section];
    SSHelpListLayoutAttributes *attribute;
    attribute = [self layoutAttributesForSupplementaryViewOfKind:_kSSListElementKindSectionFooter withIndexPath:path];
    return attribute;
}

+ (instancetype)ss_backerWithSection:(NSInteger)section
{
    NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:section];
    SSHelpListLayoutAttributes *attribute;
    attribute = [self layoutAttributesForSupplementaryViewOfKind:_kSSListElementKindSectionBack withIndexPath:path];
    return attribute;
}

@end



@implementation SSListLayoutAttributes

@end


