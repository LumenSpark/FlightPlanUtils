//
//  Foo.m
//  fpl_utils
//
//  Created by Christoph Zelazowski on 12/11/21.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

/**
 Returns true if this string contains non-white space characters.
 */
- (BOOL)isPresent
{
  return [self trimString].length > 0;
}


/**
 Trims white space and new line characters.
 */
- (NSString *)trimString
{
  return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


/**
 Returns <name> start tag.
 */
- (NSString *)startTagWithName:(NSString *)name
{
  return [NSString stringWithFormat:@"<%@>", name];
}


/**
 Returns </name> end tag.
 */
- (NSString *)endTagWithName:(NSString *)name
{
  return [NSString stringWithFormat:@"</%@>", name];
}


/**
 Extracts the value enclosed by the specified tag.
 */
- (NSString *)valueWithinTag:(NSString *)name
{
  NSString *line = self.trimString;
  NSString *startTag = [self startTagWithName:name];
  NSString *endTag = [self endTagWithName:name];
  return [line substringWithRange:NSMakeRange(startTag.length, line.length - startTag.length - endTag.length)];
}


/**
 Returns true if the specified line contains start tag.
 */
- (BOOL)containsStartTag:(NSString *)tag
{
  NSString *startTag = [self startTagWithName:tag];
  NSString *line = self.trimString;
  return [line hasPrefix:startTag];
}


/**
 Returns true if the specified line contains end tag.
 */
- (BOOL)containsEndTag:(NSString *)tag
{
  NSString *endTag = [self endTagWithName:tag];
  NSString *line = self.trimString;
  return [line hasPrefix:endTag];
}

@end
