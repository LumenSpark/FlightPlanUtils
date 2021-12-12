//
//  Waypoint.h
//  fpl_utils
//
//  Created by Christoph Zelazowski on 12/11/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Waypoint : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lon;
@property (nonatomic, strong) NSString *comment;

@end

NS_ASSUME_NONNULL_END
