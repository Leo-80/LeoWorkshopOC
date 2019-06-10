//
//  NLInAppPurchaseTool.m
//  gege
//
//  Created by leo on 2019/5/8.
//  Copyright © 2019 laoshi. All rights reserved.
//

#import "NLInAppPurchaseTool.h"
#import <StoreKit/StoreKit.h>

@interface NLInAppPurchaseTool()<SKPaymentTransactionObserver,SKProductsRequestDelegate>

@end
@implementation NLInAppPurchaseTool
static NLInAppPurchaseTool * inAppPurchaseTool = nil;

+ (instancetype)initInAppPurchaseTool{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inAppPurchaseTool = [[self alloc] init];
    });
    return inAppPurchaseTool;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (inAppPurchaseTool == nil) {
            inAppPurchaseTool = [super allocWithZone:zone];
        }
    });
    return inAppPurchaseTool;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}
- (id)copy{
    return self;
}
- (id)mutableCopy{
    return self;
}
- (void)dealloc{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}
- (BOOL)isCanPayments{
    return [SKPaymentQueue canMakePayments];
}
- (void)requestInAppProduct:(NSArray *)productIds{
    if ([self isCanPayments]) {
        NSSet * productSet = [NSSet setWithArray:productIds];
        SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:productSet];
        request.delegate  = self;
        [request start];
    }else{
        NSLog(@"不支持内购");
    }
    
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction{
    NSURL * receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData * receiptData = [NSData dataWithContentsOfURL:receiptURL];
    
    NSString * encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];

    
    NSURL * url = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"]; // 正式服务器地址:https://buy.itunes.apple.com/verifyReceipt
    
    NSMutableURLRequest * urlRequest  = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    urlRequest.HTTPMethod = @"POST";
    NSData * payloadData = [NSJSONSerialization dataWithJSONObject:@{@"receipt-data":encodeStr} options:NSJSONWritingPrettyPrinted error:nil];
    urlRequest.HTTPBody = payloadData;
    NSURLSession * session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"error %@",error);
                                                        return;
                                                    }
        
                                                    if (!data) {
                                                        NSLog(@"验证失败");
                                                        return;
                                                    }
                                                    
                                                    NSDictionary *  dict  = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                                    NSLog(@"dict : %@",dict);
                                                    NSString * productId = transaction.payment.productIdentifier;
                                                    NSString * userName = transaction.payment.applicationUsername;
                                                    NSLog(@"productId : %@ ,userName : %@",productId, userName);
                                                }];
   
    [dataTask resume];
}
#pragma mark SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    for (SKPaymentTransaction * tran in transactions) {
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:
                NSLog(@"交易完成");
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                [self completeTransaction:tran];
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"已购买过商品");
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"交易失败");
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                break;
            default:
                break;
        }
    }
}
#pragma mark SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    NSArray * products = response.products;
    if (products.count == 0) {
        NSLog(@"商品不存在");
        return;
    }
    SKProduct * requestProduct  = nil;
    for (SKProduct * pro in products) {
        if ([pro.productIdentifier isEqualToString:@"yinfu6"]) {
            requestProduct = pro;
        }
    }
    
    SKMutablePayment * payment  =  [SKMutablePayment paymentWithProduct:requestProduct];
    payment.applicationUsername = @"";
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}
@end
