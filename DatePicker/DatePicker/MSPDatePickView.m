//
//  MSPDatePickView.m
//  msp
//
//  Created by iOS on 2017/4/20.
//  Copyright © 2017年 iOS. All rights reserved.
//

#import "MSPDatePickView.h"
#import <Masonry.h>

#define kUISCRRENW [UIScreen mainScreen].bounds.size.width
#define kUISCRRENH [UIScreen mainScreen].bounds.size.height

@interface MSPDatePickView ()<UIPickerViewDelegate, UIPickerViewDataSource>

@property(nonatomic ,weak) UIPickerView *pickView;
@property(nonatomic ,weak) UIView *bgView;

@end

@implementation MSPDatePickView

-(instancetype)initWithMinDate:(NSDate *)minDate maxDate:(NSDate *)maxDate showOnlyValidDates:(BOOL)showOnly {
    
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _minDate = minDate;
        _maxDate = maxDate;
        _showOnlyValidDates = showOnly;
        _isFirstRowForDayCompont = YES;
        [self setupUI];
        [self setupCornor];
        [self initDate];
        [self showDateOnPicker:self.date];
    }
    return self;
}
//圆角
- (void)setupCornor{

    CGRect rect = CGRectMake(0, 0, self.bgView.frame.size.width, self.bgView.frame.size.height);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(15, 15)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;
    self.bgView.layer.mask = maskLayer;
}

- (void)setupUI {

    //背景View
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, kUISCRRENH, kUISCRRENW, 250)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:bgView];
    _bgView = bgView;
    //取消按钮
    UIButton *cancelBtn = [UIButton buttonWithType:0];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.layer.cornerRadius = 5;
    cancelBtn.layer.masksToBounds = YES;
    [cancelBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    //确定按钮
    UIButton *doneBtn = [UIButton buttonWithType:0];
    [doneBtn setTitle:@"确定" forState:UIControlStateNormal];
    doneBtn.layer.cornerRadius = 5;
    doneBtn.layer.masksToBounds = YES;
    [doneBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    doneBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    //分割线
    UIView *splitLine = [[UIView alloc] init];
    splitLine.backgroundColor = [UIColor lightGrayColor];
    //时间选择器
    UIPickerView *pickView = [[UIPickerView alloc]init];
    pickView.delegate = self;
    pickView.dataSource = self;
    _pickView = pickView;
    [bgView addSubview:cancelBtn];
    [bgView addSubview:doneBtn];
    [bgView addSubview:splitLine];
    [bgView addSubview:pickView];
    
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgView).offset(5);
        make.left.equalTo(bgView).offset(20);
    }];
    [doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgView).offset(5);
        make.right.equalTo(bgView).offset(-20);
    }];
    [splitLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.offset(2);
        make.right.left.equalTo(bgView);
        make.top.equalTo(doneBtn.mas_bottom).offset(5);
    }];
    [pickView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(bgView);
        make.top.equalTo(splitLine.mas_bottom).offset(-20);
        make.height.offset(240);
    }];
    [cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    
    self.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierChinese];
    
}

/**
 初始化返回日期
 */
- (void)initDate {
    
    if (self.minDate != nil && self.maxDate != nil && self.showOnlyValidDates) {
        
        NSDateComponents *components = [self.calendar components:NSCalendarUnitDay fromDate:self.minDate toDate:self.maxDate options:0];
        self.nDays = components.day + 1;
    } else {
        
        self.nDays = 10000;
    }
    NSDate *dateToPresent;
    // 最大的日期
    if ([self.minDate compare:[NSDate new]] == NSOrderedDescending) {
        dateToPresent = self.minDate;
    } else if ([self.maxDate compare:[NSDate new]] == NSOrderedAscending) {
        dateToPresent = self.maxDate;
    } else {
        dateToPresent = [NSDate new];
    }
    // 创建一个包含天时分,从最早日期到最大日期的组件
    NSDateComponents *todaysComponents = [self.calendar components:NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:self.minDate toDate:dateToPresent options:0];
    // 转换为时间戳并赋值
    NSInteger startDay = todaysComponents.day * 60 * 60 * 24;
    NSInteger startHour = todaysComponents.hour * 60 * 60;
    NSInteger startMinute = todaysComponents.minute *  60;
    //计算总时间戳
    NSTimeInterval timeInterval = (startDay + startHour + startMinute);
    // 赋值给返回的日期
    self.date = [NSDate dateWithTimeInterval:timeInterval sinceDate:self.minDate];
}

//根据日期滑动到对于的row
- (void)showDateOnPicker:(NSDate *)date {
    
    self.date = date;
    // 创一个由年月日,最早的日期组成的组件
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self.minDate];
    // 根据组件从日历中拿到NSDate
    NSDate *fromDate = [self.calendar dateFromComponents:components];
    // 创建一个日时分,从fromDate到需要显示的date的组件
    components = [self.calendar components:NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:fromDate toDate:date options:0];
    // 计算行数,在计算分钟和小时的时候,为避免滑动到第0行,加上x * (Int(INT16_MAX) / 120),其中x等于对于的进制
    NSInteger hoursRow = components.hour % 24 + (INT16_MAX) / 120 * 24;
    NSInteger minutesRow = (components.minute % 60) + (INT16_MAX) / 120 * 60;
    NSInteger daysRow = components.day;
    // 滑动到对于的行
    if (!self.isFirstRowForDayCompont) {
        
        daysRow = components.day + 1;
        if (components.minute != 0 && minutesRow % 6 == 0) {
            hoursRow ++;
        }
        [self.pickView selectRow:hoursRow inComponent:1 animated:YES];
        [self.pickView selectRow:minutesRow inComponent:2 animated:YES];
    }
    [_pickView selectRow:daysRow inComponent:0 animated:YES];
}

- (void)cancel {
    
    [self hideFromView];
}
//隐藏view
- (void)hideFromView {
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.bgView.frame;
        frame.origin.y = kUISCRRENH;
        self.bgView.frame = frame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (void) done {
    
    // 获取系统当前时区
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    // 计算与GMT时区的差
    double interval = [zone secondsFromGMTForDate:self.date];
    // 加上差的时时间戳
    NSDate *localDate = [self.date dateByAddingTimeInterval:interval];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy";
    NSString *yearString = [formatter stringFromDate:localDate];
    UILabel *dayCellViewLable = (UILabel *)[_pickView viewForRow:[_pickView selectedRowInComponent:0] forComponent:0];
    NSString *dayString = dayCellViewLable.text;
    NSString *timeString;
    if (!self.isFirstRowForDayCompont) {
        UILabel *hourCellViewLable = (UILabel *)[_pickView viewForRow:[_pickView selectedRowInComponent:1] forComponent:1];
        NSString *hourString = hourCellViewLable.text;
        UILabel *minutesCellViewLable = (UILabel *)[_pickView viewForRow:[_pickView selectedRowInComponent:2] forComponent:2];
        NSString *minutesString = minutesCellViewLable.text;
        if ([dayString isEqualToString:@"今天"]) {
            
            timeString = [NSString stringWithFormat:@"%@ %@:%@",dayString,hourString,minutesString];
        } else {
            timeString = [NSString stringWithFormat:@"%@年%@ %@:%@",yearString,dayString,hourString,minutesString];
        }
        
    } else {
        timeString = @"现在";
    }
    
    if (self.didFinishSelect) {
        self.didFinishSelect(timeString);
    }
    [self hideFromView];
}
#pragma mark : - UIPickerViewDelegate+UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    if (self.isFirstRowForDayCompont) {
        return 1;
    }
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{

    if (component == 0) {
        return self.nDays + 1;
    } else if (component == 1) {
        return INT16_MAX;
    } else {
        return INT16_MAX;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {

    switch (component) {
        case 0:
            return 200;
            break;
        case 1:
            return 60;
            break;
        case 2:
            return 60;
            break;
        default:
            return 0;
            break;
    }
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{

    return 35;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {

    // 定义一个label用于展示时间
    UILabel *datelLable = [[UILabel alloc] init];
    datelLable.font = [UIFont systemFontOfSize:18];
    datelLable.textColor = [UIColor blackColor];
    datelLable.backgroundColor = [UIColor whiteColor];
    if (component == 0) {//天数
        // 根据当前的行数转换为时间戳,记录当前行数所表示的日期
        NSDate *aDate = [NSDate dateWithTimeInterval:(double)(row - 1) * 24 * 60 * 60 sinceDate:self.minDate];
        //// 创建一个有纪元年月日组成的,当前时间的组件
        NSDateComponents *components = [self.calendar components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate new]];
        // 根据组件从日历里拿到今天的NSDate()
        NSDate *toDay = [self.calendar dateFromComponents:components];
        // 组件变为由当前行数所表示的日期组成的组件
        components = [self.calendar components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:aDate];
        // 根据组件从日历拿到当前行数表示的NSDate
        NSDate *otherDate = [self.calendar dateFromComponents:components];
        // 如果今天的NSDate等于当前行数表示的NSDate,就设置文字为今天
        if (component == 0 && row == 0) {
            datelLable.text = @"现在";
        } else if ([toDay isEqualToDate:otherDate]) {
            datelLable.text = @"今天";
        } else {
        
            // 如果不是,创建一个NSDateFormatter
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            // 地区设置
            formatter.locale = [NSLocale currentLocale];
            //日期格式设置
            formatter.dateFormat = @"M月d日";
            // label文字设置
            datelLable.text = [formatter stringFromDate:aDate];
            
            NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval a = dat.timeIntervalSince1970;
            double rowTime = a + (row - 1) * 24 * 60 * 60;
            
            datelLable.text = [NSString stringWithFormat:@"%@ %@",datelLable.text, [self getWeekdayFordate:rowTime]];
            
        }
        datelLable.textAlignment = NSTextAlignmentCenter;
    } else if (component == 1) {//小时
        // 小时的范围0-23,长度是24
        NSInteger max = [self.calendar maximumRangeOfUnit:NSCalendarUnitHour].length;
        // label文字
        datelLable.text = [NSString stringWithFormat:@"%02ld", row % max];
        datelLable.textAlignment = NSTextAlignmentLeft;
    } else if (component == 2) {
        //分钟的范围0-59,长度是60
        datelLable.text = [NSString stringWithFormat:@"%02ld", row % 60];
        datelLable.textAlignment = NSTextAlignmentLeft;
    }
    return datelLable;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{

    BOOL isFirst = self.isFirstRowForDayCompont;
    if (component == 0 && row == 0) {
        self.isFirstRowForDayCompont = YES;
    } else {
        self.isFirstRowForDayCompont = NO;
    }
    if (self.isFirstRowForDayCompont != isFirst) {
        [pickerView reloadAllComponents];
    }
    if (!(component == 0 && row == 0)) {
        // 选择的日的行数
        long daysRow = [pickerView selectedRowInComponent:0] - 1;
        // 根据行数转换为时间戳
        NSDate *chosenDate = [NSDate dateWithTimeInterval:daysRow * 24 * 60 * 60 sinceDate:self.minDate];
        // 选择的小时的行数
        NSInteger hoursRow = [pickerView selectedRowInComponent:1];
        // 选择的分钟的行数
        NSInteger minutesRow = [pickerView selectedRowInComponent:2];
        // 根据选择的日期的时间戳,创建一个有年月日的日历组件
        NSDateComponents *components = [self.calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:chosenDate];
        // 设置组件的小时
        components.hour = hoursRow % 24;
         // 设置组件的分钟
        components.minute = minutesRow % 60;
        // 根据组件从日历中拿到对应的NSDate,赋值给date
        self.date = [self.calendar dateFromComponents:components];
        // 比较date与限定的最大最小时间,如果超过最大时间或小于最小时间,就回滚到有效时间内
        if ([self.date compare:self.minDate] == NSOrderedAscending) {
            [self showDateOnPicker:self.minDate];
        } else if ([self.date compare:self.maxDate] == NSOrderedDescending) {
            [self showDateOnPicker:self.maxDate];
        }
    }
}

//根据时间戳获取星期几
- (NSString *)getWeekdayFordate:(double)date {
    
    NSArray *weekday = [[NSArray alloc]initWithObjects:@"",@"星期日",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六", nil];
    NSDate *newDate = [NSDate dateWithTimeIntervalSince1970:date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday fromDate:newDate];
    NSString *weekString = [weekday objectAtIndex:components.weekday];
    return weekString;
}


-(void)showInView{

    [self.pickView selectRow:0 inComponent:0 animated:NO];
    self.isFirstRowForDayCompont = YES;
    [self.pickView reloadAllComponents];
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.bgView.frame;
        frame.origin.y = kUISCRRENH - 250;
        self.bgView.frame = frame;
        self.hidden = NO;
    }];
}

@end






























