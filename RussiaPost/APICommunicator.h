//
//  APICommunicator.h
//  RussiaPost
//
//  Created by miles on 27.06.23.
//  Copyright (c) 2023 Miles Prower. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APICommunicator : NSObject

+ (NSDictionary *) callMethod:(NSString *)method params:(NSArray *)params post:(BOOL) post;
+ (NSDictionary *) getPackageInfo:(NSString*)barcode;

@end
