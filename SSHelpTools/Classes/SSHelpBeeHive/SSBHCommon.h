/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#ifndef SSBHCommon_h
#define SSBHCommon_h

// Debug Logging
#ifdef DEBUG
#define SSBHLog(format, ...) printf("\n[%s] %s [第%d行] %s\n", __TIME__, __PRETTY_FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String]);
#else
    #define SSBHLog(format, ...)
#endif

#endif /* BHCommon_h */
