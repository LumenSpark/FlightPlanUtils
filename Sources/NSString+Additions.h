//
//  Foo.h
//  fpl_utils
//
//  Created by Christoph Zelazowski on 12/11/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Additions)

- (BOOL)isPresent;
- (NSString *)trimString;
- (NSString *)startTagWithName:(NSString *)name;
- (NSString *)endTagWithName:(NSString *)name;
- (NSString *)valueWithinTag:(NSString *)name;
- (BOOL)containsStartTag:(NSString *)tag;
- (BOOL)containsEndTag:(NSString *)tag;

@end

NS_ASSUME_NONNULL_END
