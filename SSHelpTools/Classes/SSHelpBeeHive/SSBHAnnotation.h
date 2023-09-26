/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */


#import <Foundation/Foundation.h>
#import "SSBeeHive.h"

#ifndef SSBeehiveModSectName

#define SSBeehiveModSectName "SSBHMods"

#endif

#ifndef SSBeehiveServiceSectName

#define SSBeehiveServiceSectName "SSBHServices"

#endif


#define SSBeeHiveDATA(sectname) __attribute((used, section("__DATA,"#sectname" ")))



#define SSBeeHiveMod(name) \
class SSBeeHive; char * k##name##_mod SSBeeHiveDATA(SSBHMods) = ""#name"";

#define SSBeeHiveService(servicename,impl) \
class SSBeeHive; char * k##servicename##_service SSBeeHiveDATA(SSBHServices) = "{ \""#servicename"\" : \""#impl"\"}";

@interface SSBHAnnotation : NSObject

@end
