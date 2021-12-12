//
//  main.m
//  fpl_utils
//
//  Created by Christoph Zelazowski on 12/8/21.
//

#import <Foundation/Foundation.h>
#import "FlightPlanUtils.h"

int printUsage(void);

/**
 Application main entry point.
 */
int main(int argc, const char * argv[])
{
  @autoreleasepool {
    NSMutableArray *args = [NSMutableArray array];
    for (int i = 0; i < argc; i++) {
      NSString *str = [[NSString alloc] initWithCString:argv[i] encoding:NSUTF8StringEncoding];
      [args addObject:str];
    }
    
    if (args.count < 2) {
      return printUsage();
    }
    
    NSString *verb = ((NSString *)args[1]).lowercaseString;
    if ([verb isEqualToString:@"-waypoints"] || [verb isEqualToString:@"-w"]) {
      if (args.count == 5) {
        NSString *folderPath = args[2];
        NSString *lat = args[3];
        NSString *lon = args[4];
        [FlightPlanUtils updateWaypointsInFolder:folderPath homeBaseLat:lat homeBaseLon:lon];
      }
      else {
        return printUsage();
      }
    }
    else {
      return printUsage();
    }
  }
  return 0;
}


/**
 Prints cmd line usage
 */
int printUsage(void)
{
  printf("Usage: fpl_utils [-waypoints folder_path home_base_lat home_base_lon]\n\n");
  printf("Example:\n");
  printf("fpl_utils -waypoints ~/Library/Mobile\\ Documents/com~apple~CloudDocs/Flight\\ Routes/ 47.53 -122.30\n\n");
  return 0;
}
