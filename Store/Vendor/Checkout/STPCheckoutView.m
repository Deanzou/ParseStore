//
//  STPCheckoutView.m
//  Checkout Example
//
//  Created by Alex MacCaw on 2/14/13.
//  Copyright (c) 2013 Stripe. All rights reserved.
//

#import "STPCheckoutView.h"

@implementation STPCheckoutView

@synthesize paymentView, key, pending;

- (id)initWithFrame: (CGRect)frame andKey: (NSString*)stripeKey
{
    self = [self initWithFrame:frame];
    if (self) {
        self.key = stripeKey;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.paymentView = [[STPPaymentCardTextField alloc] initWithFrame:CGRectMake(0,0,290,55)];
        self.paymentView.delegate = self;
        [self addSubview:self.paymentView];
    }
    return self;
}

- (void)paymentView:(STPPaymentCardTextField*)paymentView withCard:(STPCard *)card isValid:(BOOL)valid
{
    if ([self.delegate respondsToSelector:@selector(checkoutView:withCard:isValid:)]) {
        [self.delegate checkoutView:self withCard:card isValid:valid];
    }
}

- (void)pendingHandler:(BOOL)isPending
{
    pending = isPending;
    self.userInteractionEnabled = !pending;
}

- (void)createToken:(STPCheckoutTokenBlock)block
{
    if ( pending ) return;
    
    if ( ![self.paymentView isValid] ) {
        NSError* error = [[NSError alloc] initWithDomain:StripeDomain
                                                    code:STPCardError
                                                userInfo:@{NSLocalizedDescriptionKey: STPCardErrorUserMessage}];

        block(nil, error);
        return;
    }
    
    [self endEditing:YES];
 
    STPCard* card = self.paymentView.card;
    STPCard* scard = [[STPCard alloc] init];
    
    scard.number = card.number;
    scard.expMonth = card.expMonth;
    scard.expYear = card.expYear;
    scard.cvc = card.cvc;
    
    [self pendingHandler:YES];
    [[STPAPIClient sharedClient] createTokenWithCard:scard
                     completion:^(STPToken *token, NSError *error) {
                     [self pendingHandler:NO];
                     block(token, error);
                 }];

}

@end
