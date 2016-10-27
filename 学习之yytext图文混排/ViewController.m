//
//  ViewController.m
//  学习之yytext图文混排
//
//  Created by huochaihy on 16/10/18.
//  Copyright © 2016年 CHL. All rights reserved.
//

#import "ViewController.h"
#import "CommunityTableViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CommunityTableViewController * community = [[CommunityTableViewController alloc]initWithStyle:UITableViewStylePlain];
    [self addChildViewController:community];
    
    community.tableView.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-20);
    [self.view addSubview:community.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
