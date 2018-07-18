//
//  CreditCardBinChecker.m
//  Tricae
//
//  Created by Thiago Lioy on 9/10/14.
//  Copyright (c) 2014 Comercio BF LTDA. All rights reserved.
//

#import "CreditCardBinChecker.h"

@interface CreditCardBinChecker ()
@property(nonatomic,strong)NSArray *binRules;
@end

@implementation CreditCardBinChecker

// 20180718 Updated using: https://github.com/braintree/credit-card-type/blob/master/index.js
+(CreditCardBinChecker*)shareManager{
    static CreditCardBinChecker *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[self alloc] init];
        shareManager.binRules = @[
                                  @{
                                      @"issuer": @"visa",
                                      @"maxNumbers": @[@16, @18, @19],
                                      @"maxSecurityCardCode": @3,
                                      @"regex": @"^4\\d*$",
                                      @"gaps": @[@4, @8, @12],
                                      },
                                  @{
                                      @"issuer": @"mastercard",
                                      @"maxNumbers": @[@16],
                                      @"maxSecurityCardCode": @3,
                                      @"regex": @"^(5[1-5]|222[1-9]|22[3-9]|2[3-6]|27[0-1]|2720)\\d*$",
                                      @"gaps": @[@4, @8, @12],
                                      },
                                  @{
                                      @"issuer": @"amex",
                                      @"maxNumbers": @[@15],
                                      @"maxSecurityCardCode": @4,
                                      @"regex": @"^3[47]\\d*$",
                                      @"gaps": @[@4, @10],
                                      },
                                  @{
                                      @"issuer": @"diners",
                                      @"maxNumbers": @[@14, @16, @19],
                                      @"maxSecurityCardCode": @3,
                                      @"regex": @"^3(0[0-5]|[689])\\d*$",
                                      @"gaps": @[@4, @10],
                                      },
                                  @{
                                      @"issuer": @"discover",
                                      @"maxNumbers": @[@16, @19],
                                      @"maxSecurityCardCode": @3,
                                      @"regex": @"^(6011|65|64[4-9])\\d*",
                                      @"gaps": @[@4, @8, @12],
                                      },
                                  @{
                                      @"issuer": @"jcb",
                                      @"maxNumbers": @[@16, @17, @18, @19],
                                      @"maxSecurityCardCode": @3,
                                      @"regex": @"^(2131|1800|35)\\d*$",
                                      @"gaps": @[@4, @8, @12],
                                      },
                                  @{
                                      @"issuer": @"unionpay",
                                      @"maxNumbers": @[@16, @17, @18, @19],
                                      @"maxSecurityCardCode": @3,
                                      @"regex": @"^(((620|(621(?!83|88|98|99))|622(?!06|018)|62[3-6]|627[02,06,07]|628(?!0|1)|629[1,2]))\\d*|622018\\d{12})$",
                                      @"gaps": @[@4, @8, @12],
                                      },
                                  @{
                                      @"issuer": @"maestro",
                                      @"maxNumbers": @[@12, @13, @14, @15, @16, @17, @18, @19],
                                      @"maxSecurityCardCode": @3,
                                      @"regex": @"^(5[06-9]|6[37])\\d*$"
                                      },
                                  
                                  @{
                                      @"issuer": @"mir",
                                      @"maxNumbers": @[@16, @17, @18, @19],
                                      @"maxSecurityCardCode": @3,
                                      @"regex" : @"^(220[0-4])\\d*$"
                                      }
                                  ];
        
    });
    return shareManager;
}

+(CardBinRule*)binRule:(NSString*)cardNumber{
    for(NSDictionary *dc in [self shareManager].binRules){
        CardBinRule *rule = [CardBinRule cardBinRule:dc];
        if([[self shareManager] matchCardNumber:cardNumber
                                    withPattern:rule.regex])
        return rule;
    }
    return nil;
}

-(BOOL)matchCardNumber:(NSString*)cardNumber withPattern:(NSString*)pattern {
    NSPredicate *myTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    
    if([myTest evaluateWithObject:cardNumber]) {
        return YES;
    }
    
    return NO;
}

+(BOOL)isValidCard:(NSString*)cardNumber{
    CardBinRule *rule = [CreditCardBinChecker binRule:cardNumber];
    
    if (rule && [CreditCardBinChecker checkNumber:cardNumber]) {
        for (NSNumber *maxNumber in rule.maxNumbers) {
            if ([maxNumber intValue] == cardNumber.length)
            return YES;
        }
    }
    return NO;
}

+(BOOL)checkNumber:(NSString*)cardNumber{
    BOOL odd = true;
    int sum = 0;
    for (NSInteger i = cardNumber.length - 1; i >= 0; i --) {
        int digitInt = [[NSString stringWithFormat:@"%c", [cardNumber characterAtIndex:i]] intValue];
        
        if ((odd = !odd))
        digitInt *= 2;
        
        if (digitInt > 9)
        digitInt -= 9;
        
        sum += digitInt;
    }
    
    return ((sum % 10) == 0);
}

@end
