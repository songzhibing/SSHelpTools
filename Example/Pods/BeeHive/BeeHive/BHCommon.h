/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#ifndef BHCommon_h
#define BHCommon_h

// Debug Logging
#ifdef DEBUG
#define BHLog(format, ...) printf("\n[%s] %s [第%d行] %s\n", __TIME__, __PRETTY_FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String]);

#else
#define BHLog(x, ...)
#endif

#endif /* BHCommon_h */
