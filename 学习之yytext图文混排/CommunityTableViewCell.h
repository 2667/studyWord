//
//  CommunityTableViewCell.h
//  学习之yytext图文混排
//
//  Created by huochaihy on 16/10/18.
//  Copyright © 2016年 CHL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommunityModel.h"
#import "CommunityLayout.h"


#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kWBCellContentWidth (kScreenWidth - 2 * kWBCellPadding) // cell 内容宽度
#define kWBCellPadding 12       // cell 内边距

@interface CommunityTableViewCell : UITableViewCell


-(void)refreshCellWith:(CommunityLayout *)layout;

@end
