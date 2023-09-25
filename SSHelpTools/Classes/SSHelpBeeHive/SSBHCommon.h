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
#define SSBHLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define SSBHLog(x, ...)
#endif

#endif /* BHCommon_h */
