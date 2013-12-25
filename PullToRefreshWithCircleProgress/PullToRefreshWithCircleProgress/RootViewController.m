//
//  RootViewController.m
//  PullToRefreshWithCircleProgress
//
//  Created by Yang Shichang on 13-12-25.
//  Copyright (c) 2013年 Yang152412. All rights reserved.
//

#import "RootViewController.h"
#import "UITableView+UzysCircularProgressPullToRefresh.h"
#define CELLIDENTIFIER @"CELL"

@interface RootViewController ()

@property (nonatomic,strong) UzysRadialProgressActivityIndicator *radialIndicator;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *pData;

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupDataSource];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.title = @"UzysCircularProgressPullToRefresh";
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 7.0) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20+44, self.view.bounds.size.width, self.view.bounds.size.height - 20-44) style:UITableViewStylePlain];
    } else {
        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELLIDENTIFIER];
    [self.view addSubview:self.tableView];
    
    __weak typeof(self) weakSelf =self;
    
    //Because of self.automaticallyAdjustsScrollViewInsets you must add code below in viewWillApper
    [_tableView addPullToRefreshActionHandler:^{
        [weakSelf insertRowAtTop];
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //manually triggered pulltorefresh
    [_tableView triggerPullToRefresh];
}

#pragma mark UITableView DataManagement
- (void)setupDataSource {
    self.pData = [NSMutableArray array];
    [self.pData addObject:@"0"];
    [self.pData addObject:@"1"];
    [self.pData addObject:@"2"];
    [self.pData addObject:@"3"];
    
    for(int i=0; i<3; i++)
        [self.pData addObject:[NSDate dateWithTimeIntervalSinceNow:-(i*100)]];
}

- (void)insertRowAtTop {
    __weak typeof(self) weakSelf = self;
    
    int64_t delayInSeconds = 2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakSelf.tableView beginUpdates];
        [weakSelf.pData insertObject:[NSDate date] atIndex:0];
        [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [weakSelf.tableView endUpdates];
        
        //Stop PullToRefresh Activity Animation
        [weakSelf.tableView stopRefreshAnimation];
    });
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CELLIDENTIFIER];
    
    if([[self.pData objectAtIndex:indexPath.row] isKindOfClass:[NSString class]] && [[self.pData objectAtIndex:indexPath.row] isEqualToString:@"0"])
    {
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.text = @"Changing Size";
    }
    else if([[self.pData objectAtIndex:indexPath.row] isKindOfClass:[NSString class]] &&[[self.pData objectAtIndex:indexPath.row] isEqualToString:@"1"])
    {
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.text = @"Chaging BorderWidth";
    }
    else if([[self.pData objectAtIndex:indexPath.row] isKindOfClass:[NSString class]] &&[[self.pData objectAtIndex:indexPath.row] isEqualToString:@"2"])
    {
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.text = @"Changing image";
    }
    else if([[self.pData objectAtIndex:indexPath.row] isKindOfClass:[NSString class]] &&[[self.pData objectAtIndex:indexPath.row] isEqualToString:@"3"])
    {
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.text = @"Changing borderColor";
    }
    else
    {
        NSDate *date = [self.pData objectAtIndex:indexPath.row];
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.text = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterMediumStyle];
    }
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[self.pData objectAtIndex:indexPath.row] isKindOfClass:[NSString class]] && [[self.pData objectAtIndex:indexPath.row] isEqualToString:@"0"])
    {
        [self.tableView.pullToRefreshView setSize:CGSizeMake(40, 40)];
    }
    else if([[self.pData objectAtIndex:indexPath.row] isKindOfClass:[NSString class]] && [[self.pData objectAtIndex:indexPath.row] isEqualToString:@"1"])
    {
        [self.tableView.pullToRefreshView setBorderWidth:4];
    }
    else if([[self.pData objectAtIndex:indexPath.row] isKindOfClass:[NSString class]] && [[self.pData objectAtIndex:indexPath.row] isEqualToString:@"2"])
    {
        [self.tableView.pullToRefreshView setImageIcon:[UIImage imageNamed:@"thunderbird"]];
    }
    else if([[self.pData objectAtIndex:indexPath.row] isKindOfClass:[NSString class]] && [[self.pData objectAtIndex:indexPath.row] isEqualToString:@"3"])
    {
        [self.tableView.pullToRefreshView setBorderColor:[UIColor colorWithRed:75/255.0 green:131/255.0 blue:188/255.0 alpha:1.0]];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
