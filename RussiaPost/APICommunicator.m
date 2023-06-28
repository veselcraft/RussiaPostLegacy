//
//  APICommunicator.m
//  RussiaPost
//
//  Created by miles on 27.06.23.
//  Copyright (c) 2023 Miles Prower. All rights reserved.
//

#import "APICommunicator.h"

@interface APICommunicator ()

@end

@implementation APICommunicator

+ (NSDictionary *) callMethod:(NSString *)method params:(NSArray *)params post:(BOOL) post {
    NSString *URL = @"";
    
    URL = [URL stringByAppendingString:@"https://www.pochta.ru/"];
    URL = [URL stringByAppendingString:method];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URL]];
    
    NSData *cookieData = [[NSUserDefaults standardUserDefaults] objectForKey:@"ApplicationCookie"];
    if ([cookieData length] > 0) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookieData];
        for (NSHTTPCookie *cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
    
    [request setHTTPShouldHandleCookies:YES];
    [request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]]];
    
    NSString *httpparams = @"";
    
    for (id param in params) {
        httpparams = [httpparams stringByAppendingFormat:@"%@=%@&", param[0], param[1]];
    }
    
    if (post) {
        [request setHTTPMethod:@"POST"];
        NSData *postData = [httpparams dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        [request setHTTPBody:postData];
        [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    } else {
        [request setHTTPMethod:@"GET"];
    }
    
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if (error == nil || oResponseData != nil) {
        NSError *errorJSON = nil;
        id object = [NSJSONSerialization
                     JSONObjectWithData:oResponseData options:0 error:&errorJSON];
        
        NSData *cookieData = [NSKeyedArchiver archivedDataWithRootObject:[NSHTTPCookie cookiesWithResponseHeaderFields:[responseCode allHeaderFields] forURL:[NSURL URLWithString:@""]]];
        [[NSUserDefaults standardUserDefaults] setObject:cookieData forKey:@"ApplicationCookie"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (!errorJSON && [object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = object;
            NSLog(@"@%@", response);
            if ([responseCode statusCode] == 200) {
                return response;
            } else {
                return response;
            }
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

+ (NSDictionary *) getPackageInfo:(NSString*)barcode
{
    return [self callMethod:[NSString stringWithFormat:@"api/tracking/api/v1/trackings/by-barcodes?language=ru&track-numbers=%@", barcode] params:nil post:false];
}

@end
