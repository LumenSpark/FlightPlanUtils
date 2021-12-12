//
//  RoutePoint.h
//  fpl_utils
//
//  Created by Christoph Zelazowski on 12/11/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoutePoint : NSObject

@property (nonatomic, strong) NSString *waypointIdentifier;
@property (nonatomic, strong) NSString *waypointType;
@property (nonatomic, strong) NSString *waypointCountryCode;

@end

NS_ASSUME_NONNULL_END
