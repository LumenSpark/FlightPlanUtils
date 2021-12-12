//
//  FlightPlan.h
//  fpl_utils
//
//  Created by Christoph Zelazowski on 12/11/21.
//

#import <Foundation/Foundation.h>
#import "Waypoint.h"
#import "RoutePoint.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlightPlan : NSObject

@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSString *routeName;
@property (nonatomic, strong) NSArray *waypoints;
@property (nonatomic, strong) NSArray *routePoints;

@end

NS_ASSUME_NONNULL_END
