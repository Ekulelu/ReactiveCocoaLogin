//
//  ViewController.m
//  ReactiveCocoaTest
//
//  Created by 黄政 on 2016/11/26.
//  Copyright © 2016年 ekulelu. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveCocoa.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *accountTV;
@property (weak, nonatomic) IBOutlet UITextField *passwordTV;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    RAC(self.loginBtn, enabled) = [RACSignal combineLatest:
//                                   @[self.accountTV.rac_textSignal,
//                                     self.passwordTV.rac_textSignal]
//        reduce:^id{
//        return @(self.accountTV.text.length > 5 && self.passwordTV.text.length > 5);
//    }];
//    
//
//    
//    [[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
//        if ([self.accountTV.text isEqualToString:@"aahuang"]
//            && [self.passwordTV.text isEqualToString:@"aahuang"]) {
//            NSLog(@"login!");
//        } else {
//            NSLog(@"Invaild account or password ");
//        }
//    }];
    
    
    
    RACSignal *accountValidSignal =
        [self.accountTV.rac_textSignal map:^id(id value) {
        return @(self.accountTV.text.length > 5);
    }];
    
    RACSignal *passwordValidSignal =
    [self.passwordTV.rac_textSignal map:^id(id value) {
        return @(self.passwordTV.text.length > 5);
    }];
    
    RAC(self.accountTV, backgroundColor) =
    [accountValidSignal map:^id(NSNumber* accountValid) {
        return accountValid.boolValue ? [UIColor whiteColor] : [UIColor redColor];
    }];
    
    RAC(self.passwordTV, backgroundColor) =
    [passwordValidSignal map:^id(NSNumber* passwordValid) {
        return passwordValid.boolValue ? [UIColor whiteColor] : [UIColor redColor];
    }];
    
    RAC(self.loginBtn, enabled) =
    [RACSignal combineLatest:@[accountValidSignal, passwordValidSignal]
              reduce:^id(NSNumber* accountValid, NSNumber* passwordValid){
                  return @(accountValid.boolValue && passwordValid.boolValue);
    }];
    
    [[[[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside]
       doNext:^(id x) {
        self.loginBtn.enabled = NO;
    }]
      flattenMap:^id(id value) {
        return [self signInSignal];
    }] subscribeNext:^(NSNumber* isLogin) {
        self.loginBtn.enabled = YES;
        if (isLogin.boolValue) {
            NSLog(@"login!");
        } else {
            NSLog(@"Invaild account or password ");
        }
    }];
//    [[[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside]
//      flattenMap:^RACStream *(id value) {
//        return [self signInSignal];
//    }] subscribeNext:^(NSNumber* isLogin) {
//        if (isLogin.boolValue) {
//            NSLog(@"login!");
//        } else {
//            NSLog(@"Invaild account or password ");
//        }
//    }];
    
}


- (RACSignal*)signInSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self signInWithAccount:self.accountTV.text
         password:self.passwordTV.text
         complete:^(Boolean success){
             [subscriber sendNext:@(success)];
             [subscriber sendCompleted];
         }];
        return nil;
    }];
}


- (void)signInWithAccount:(NSString *)account password:(NSString *)password complete:(void(^)(Boolean success))completeBlock {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        BOOL success = [account isEqualToString:@"aahuang"] && [password isEqualToString:@"aahuang"];
        completeBlock(success);
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
