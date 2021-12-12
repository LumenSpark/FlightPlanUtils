//
//  FlightPlanUtils.h
//  fpl_utils
//
//  Created by Christoph Zelazowski on 12/11/21.
//

#import <Foundation/Foundation.h>
#import "FlightPlan.h"
@import CoreLocation;

NS_ASSUME_NONNULL_BEGIN

#define Log(format,...) [FlightPlanUtils output:(format), ##__VA_ARGS__]

extern CLLocation *_homeBaseLocation;

@interface FlightPlanUtils : NSObject

+ (void)updateWaypointsInFolder:(NSString *)folderPath homeBaseLat:(NSString *)lat homeBaseLon:(NSString *)lon;

@end

NS_ASSUME_NONNULL_END
