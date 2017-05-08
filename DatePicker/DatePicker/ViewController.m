//
//  ViewController.m
//  DatePicker
//
//  Created by 李江波 on 2017/5/7.
//  Copyright © 2017年 lijiangbo. All rights reserved.
//

#import "ViewController.h"
#import "MSPDatePickView.h"

@interface ViewController ()
@property(nonatomic ,strong) MSPDatePickView *datePicker;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)datePickerClick:(UIButton *)sender {
    
    _datePicker = [[MSPDatePickView alloc]initWithMinDate:[[NSDate alloc] init] maxDate:[NSDate dateWithTimeInterval:365 * 24 * 60 * 60 sinceDate:[NSDate new]] showOnlyValidDates:YES];
    [self.view addSubview:_datePicker];
    [_datePicker showInView];
    _datePicker.didFinishSelect = ^(NSString *timeString) {
        
        [sender setTitle:timeString forState:UIControlStateNormal];
    };
}

@end
