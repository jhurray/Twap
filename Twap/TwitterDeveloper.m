//
//  TwitterDeveloper.m
//  MapTwitter
//
//  Created by Li Yan on 3/14/13.
//  Copyright (c) 2013 Li Yan. All rights reserved.
//

#import "TwitterDeveloper.h"

@implementation TwitterDeveloper

@synthesize consumer_key;
@synthesize consumer_secret;
@synthesize access_token;
@synthesize access_token_secret;

- (TwitterDeveloper *)initAsDeveloper
{
    self = [super init];
    
    //SET THIS TO MY OWN
    /*
     
     from https://dev.twitter.com/apps/5759423/show
     
     [self setAccess_token:@""];
     [self setAccess_token_secret:@""];
     */
    return self;
}

- (void)tweetsSearch:(NSString *)URLString GeoLocation:(CLLocationCoordinate2D)geocode Range:(double)range withBlock:(void (^)(NSArray *arr))block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ACAccountStore *account = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            
            if (granted)
            {
                NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
                if (arrayOfAccounts.count > 0)
                {
                    NSURL *requestURL = [NSURL URLWithString:URLString];
                    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                    NSString *geoString = [[NSString alloc] initWithFormat:@"%f,%f,%fmi", geocode.latitude, geocode.longitude, range];
                    [parameters setObject:geoString forKey:@"geocode"];
                    [parameters setObject:@"200" forKey:@"count"];
                    //[parameters setObject:@"" forKey:@"q"];
                    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:requestURL parameters:parameters];
                    [request setAccount:arrayOfAccounts[0]];
                    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                     {
                         //NSError *error = nil;
                         NSDictionary *tweetsDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&error];
                         tweetsDic = [tweetsDic objectForKey:@"statuses"];
                         NSLog(@"\nFetching tweets...%lu\n", (unsigned long)[tweetsDic count]);
                         
                         NSMutableArray *geoTweets = [NSMutableArray array];
                         for (NSDictionary *subDic in tweetsDic)
                         {
                             NSString *geoString = [[NSString alloc] initWithFormat:@"%@", [subDic objectForKey:@"geo"]];
                             if (![geoString isEqualToString:@"<null>"])
                                 //Tweets that have "geo"
                             {
                                 //NSLog(@"geostring is %@\n", geoString);
                                 Tweet *tweet = [[Tweet alloc] initWithJSONDic:subDic];
                                 [geoTweets addObject:tweet];
                                 
                             }
                         }
                         dispatch_sync(dispatch_get_main_queue(), ^{
                             block([NSArray arrayWithArray:geoTweets]);
                         });
                     }];
                }
                else
                {
                    NSLog(@"No available account!");
                }
            }
            else
            {
                NSLog(@"Not granted!");
            }
            
            
        }];
    });
}

- (void)retweet:(NSString *)id_str
{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
    {
        if (granted)
        {
            NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
            ACAccount *twitter_account = [arrayOfAccounts objectAtIndex:0];
            ACAccountCredential *twitter_account_credential = [[ACAccountCredential alloc] initWithOAuthToken:self.access_token tokenSecret:self.access_token_secret];
            [twitter_account setCredential:twitter_account_credential];
            
            NSString *URLString = [[NSString alloc] initWithFormat:@"https://api.twitter.com/1.1/statuses/retweet/%@.json", id_str];
            NSURL *requestURL = [NSURL URLWithString:URLString];
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:requestURL parameters:nil];
            [request setAccount:twitter_account];
            [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {}];
        }
        else
        {
            NSLog(@"Not granted!");
        }
    }];
}

- (void)favorite:(NSString *)id_str Is_Create:(BOOL)is_create
{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
    {
        if (granted)
        {
            NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
            if (arrayOfAccounts.count > 0)
            {
                ACAccount *twitter_account = [arrayOfAccounts objectAtIndex:0];
                ACAccountCredential *twitter_account_credential = [[ACAccountCredential alloc] initWithOAuthToken:self.access_token tokenSecret:self.access_token_secret];
                [twitter_account setCredential:twitter_account_credential];
                
                NSString *URLString = nil;
                if (is_create) URLString = [[NSString alloc] initWithFormat:@"https://api.twitter.com/1.1/favorites/create.json"];
                else URLString = [[NSString alloc] initWithFormat:@"https://api.twitter.com/1.1/favorites/destroy.json"];
                NSURL *requestURL = [NSURL URLWithString:URLString];
                NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                [parameters setObject:id_str forKey:@"id"];
                SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:requestURL parameters:parameters];
                [request setAccount:twitter_account];
                [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {}];
            }
            else
            {
                NSLog(@"No available account!");
            }
        }
        else
        {
            NSLog(@"Not granted!");
        }
    }];
}

- (NSData *)getFavorite
{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    __block NSData *favoriteData = nil;
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
             if (arrayOfAccounts.count > 0)
             {
                 ACAccount *twitter_account = [arrayOfAccounts objectAtIndex:0];
                 ACAccountCredential *twitter_account_credential = [[ACAccountCredential alloc] initWithOAuthToken:self.access_token tokenSecret:self.access_token_secret];
                 [twitter_account setCredential:twitter_account_credential];
                 
                 NSString *URLString = nil;
                 URLString = [[NSString alloc] initWithFormat:@"https://api.twitter.com/1.1/favorites/list.json"];
                 NSURL *requestURL = [NSURL URLWithString:URLString];
                 NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:requestURL parameters:parameters];
                 [request setAccount:twitter_account];
                 [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                 {
                     favoriteData = responseData;
                 }];
             }
             else
             {
                 NSLog(@"No available account!");
             }
         }
         else
         {
             NSLog(@"Not granted!");
         }
     }];
    while (favoriteData == nil)
    {
        sleep(1);
    }
    return favoriteData;
}

- (NSData *)timeLine
{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    __block NSData *timelineData = nil;
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
             if (arrayOfAccounts.count > 0)
             {
                 ACAccount *twitter_account = [arrayOfAccounts objectAtIndex:0];
                 ACAccountCredential *twitter_account_credential = [[ACAccountCredential alloc] initWithOAuthToken:self.access_token tokenSecret:self.access_token_secret];
                 [twitter_account setCredential:twitter_account_credential];
                 
                 NSString *URLString = nil;
                 URLString = [[NSString alloc] initWithFormat:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
                 NSURL *requestURL = [NSURL URLWithString:URLString];
                 NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                 [parameters setObject:@"200" forKey:@"count"];
                 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:requestURL parameters:parameters];
                 [request setAccount:twitter_account];
                 [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                  {
                      timelineData = responseData;
                  }];
             }
             else
             {
                 NSLog(@"No available account!");
             }
         }
         else
         {
             NSLog(@"Not granted!");
         }
     }];
    while (timelineData == nil)
    {
        sleep(1);
    }
    return timelineData;
}

@end
