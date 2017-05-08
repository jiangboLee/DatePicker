//
//  MSPDatePickView.h
//  msp
//
//  Created by iOS on 2017/4/20.
//  Copyright © 2017年 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DidFinishSelect)(NSString *timeString);

@interface MSPDatePickView : UIView
//日历
@property(nonatomic ,strong) NSCalendar *calendar;
//最小日期
@property(nonatomic ,strong) NSDate *minDate;
//最大日期
@property(nonatomic ,strong) NSDate *maxDate;
//显示日期行数
@property(nonatomic ,assign) NSInteger nDays;
//是否只显示有效日期
@property(nonatomic ,assign) BOOL showOnlyValidDates;
// 保存最终返回的日期
@property(nonatomic ,strong) NSDate *date;

@property(nonatomic ,assign) BOOL isFirstRowForDayCompont;

- (instancetype)initWithMinDate:(NSDate *)minDate maxDate:(NSDate *)maxDate showOnlyValidDates:(BOOL)showOnly;

- (void)showInView;

@property(nonatomic ,copy) DidFinishSelect didFinishSelect;
@end












