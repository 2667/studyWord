//
//  CommunityTableViewCell.m
//  学习之yytext图文混排
//
//  Created by huochaihy on 16/10/18.
//  Copyright © 2016年 CHL. All rights reserved.
//

#import "CommunityTableViewCell.h"
#import "YYText.h"
#import "UIView+YYText.h"
#import "CommunityLayout.h"
#import "UIImageView+WebCache.h"

@interface CommunityTableViewCell ()

@property(nonatomic,strong)UIImageView * iconImageView;///头像

@property(nonatomic,strong)YYLabel * nameLabel;/// 名字

@property(nonatomic,strong)YYLabel * timeLabel;///时间 来源

@property(nonatomic,strong)YYLabel * connectLabel;/// 文本

@property(nonatomic,strong)NSMutableArray * imageArray;///图片数组

@property(nonatomic,strong)CommunityLayout * layout;///数据源

@property(nonatomic,strong)YYLabel * RetweetLabel;/// 转发文本

@property(nonatomic,strong)UIView * RetweetBackView;/// 转发view

@property(nonatomic,strong)UIView * cardBackView;/// 卡片view

@property(nonatomic,strong)YYLabel * cardTextLabel;/// 卡片的文本

@property(nonatomic,strong)UIImageView * badgeImageView;///卡片的角标

@property(nonatomic,strong)UIImageView * cardImageView;/// 卡片的图片

@property(nonatomic,strong)UIButton * cardBtn;/// 卡片按钮

@property(nonatomic,strong)UIView * toolView; /// 工具条
@end
@implementation CommunityTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //        初始化
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    self.contentView.backgroundColor = kWBCellBackgroundColor;
    self.iconImageView = [[UIImageView alloc]init];
    self.nameLabel = [YYLabel new];
    self.timeLabel = [[YYLabel alloc]init];
    self.connectLabel = [YYLabel new];
    
    self.RetweetBackView = [[UIView alloc]init];
    self.RetweetBackView.backgroundColor = kWBCellHighlightColor;
    
    self.RetweetLabel = [YYLabel new];
    
    self.cardBackView = [[UIView alloc]init];
    self.cardTextLabel = [YYLabel new];
    self.badgeImageView = [[UIImageView alloc]init];
    self.cardImageView = [[UIImageView alloc]init];
    
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.connectLabel];
    
    [self.RetweetBackView addSubview:self.RetweetLabel];
    [self.contentView addSubview:self.RetweetBackView];
    self.RetweetBackView.hidden = YES;
    
    [self.cardBackView addSubview:self.badgeImageView];
    [self.cardBackView addSubview:self.cardTextLabel];
    [self.cardBackView addSubview:self.cardImageView];
    [self.cardBackView addSubview:self.cardBtn];
    
    self.cardBackView.hidden = YES;
//    self.cardBackView.layer.borderColor = kWBCellHighlightColor.CGColor;
//    self.cardBackView.layer.borderWidth = 1;
    self.cardBackView.backgroundColor = kWBCellInnerViewColor;
    
    self.imageArray = [NSMutableArray array];
    
    for (NSInteger i =0; i< 9; i++) {
        UIImageView * imageView = [[UIImageView alloc]init];
        imageView.hidden = YES;
        [_imageArray addObject:imageView];
    }
    
    self.toolView  = [[UIView alloc]init];
    [self.contentView addSubview:self.toolView];
}

-(void)refreshCellWith:(CommunityLayout *)layout{
    self.layout = layout;
    //    头像
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:layout.status.user.avatarLarge.absoluteString]];
    self.iconImageView.layer.cornerRadius = 22;
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.frame = CGRectMake(kWBCellTopMargin, kWBCellTopMargin, 44, 44);
    
    
    //  名字
    self.nameLabel.textLayout = layout.nameTextLayout;
    self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame)+kWBCellTopMargin, CGRectGetMinY(self.iconImageView.frame), kWBCellNameWidth, 24);
    
    
    //  时间
    self.timeLabel.textLayout = layout.sourceTextLayout;
    self.timeLabel.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetMaxY(self.nameLabel.frame), kWBCellNameWidth, 24.0);
    

    //    文本
    self.connectLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
    self.connectLabel.displaysAsynchronously = YES;
    self.connectLabel.ignoreCommonProperties = YES;
    self.connectLabel.fadeOnAsynchronouslyDisplay = NO;
    self.connectLabel.fadeOnHighlight = NO;
    self.connectLabel.frame = CGRectMake(kWBCellPadding, CGRectGetMaxY(self.iconImageView.frame)+kWBCellTopMargin, kWBCellContentWidth, layout.titleHeight);
    
    self.connectLabel.numberOfLines = 0;
    self.connectLabel.textLayout = layout.titleTextLayout;
    
    
    [self.cardBackView removeFromSuperview];
    self.RetweetBackView.hidden = YES;
    for (UIImageView * imageView in self.imageArray) {
        imageView.hidden = YES;
    }
    
    //     优先级 转发 -- 图片 -- 卡片
    if (layout.retweetHeight > 0) {
        //      有转发内容
        //  转发的内容
        self.RetweetBackView.hidden = NO;
        CGFloat retweetHeight = 0.0;
        self.RetweetLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
        self.RetweetLabel.displaysAsynchronously = YES;
        self.RetweetLabel.ignoreCommonProperties = YES;
        self.RetweetLabel.fadeOnAsynchronouslyDisplay = NO;
        self.RetweetLabel.fadeOnHighlight = NO;
        self.RetweetLabel.frame = CGRectMake(kWBCellPadding,4, kWBCellContentWidth, layout.retweetTextHeight);
        
        self.RetweetLabel.numberOfLines = 0;
        self.RetweetLabel.textLayout = layout.retweetTextLayout;
        
        retweetHeight = layout.retweetTextHeight;
        
        if (layout.retweetPicHeight > 0) {
            //            图片
            [self setimageWithFrame:self.RetweetLabel isRetweet:YES];
        }else if (layout.retweetCardHeight >0){
            //            卡片
            self.cardBackView.hidden = NO;
            [self setCardWithFrame:self.RetweetLabel isRetweet:YES];
        }
        
        self.RetweetBackView.frame = CGRectMake(0, CGRectGetMaxY(self.connectLabel.frame),self.frame.size.width,layout.retweetHeight+2*kWBCellPaddingPic);
        
    }else if(layout.picHeight > 0){

        [self setimageWithFrame:self.connectLabel isRetweet:NO];
    }else{
        //        卡片
        self.cardBackView.hidden = NO;
        [self setCardWithFrame:self.connectLabel isRetweet:NO];

    }
    
    [self settoolView];
}

-(void)setimageWithFrame:(UIView * )view isRetweet:(BOOL)isRetweet{
    
    CGSize picSize = isRetweet ? _layout.retweetPicSize : _layout.picSize;
    NSArray *pics = isRetweet ? _layout.status.retweetedStatus.pics : _layout.status.pics;
    
    for (NSInteger i =0; i< 9; i++) {
        UIImageView * imageView = self.imageArray[i];
        if (i >= pics.count) {
            imageView.hidden = YES;
        }else{
            NSInteger row = i%3;
            NSInteger column = i/3;
            if (i == 2 && pics.count == 4) {
                row = 0;
                column = 1;
            }else if(i == 3 && pics.count == 4 ){
                row = 1;
                column = 1;
            }
            imageView.hidden = NO;
            WBPicture * pic = pics[i];
            [imageView sd_setImageWithURL:[NSURL URLWithString:pic.bmiddle.url.absoluteString] placeholderImage:[UIImage imageNamed:@"icon.jpg"]];
            if (isRetweet) {
                //                转发
                imageView.frame =CGRectMake(kWBCellPadding+(kWBCellPaddingPic +picSize.width)*row,CGRectGetMaxY(self.RetweetLabel.frame)+(kWBCellPaddingPic+picSize.height)*column, picSize.width, picSize.height);
                
                [self.RetweetBackView addSubview:imageView];
            }else{
                
                imageView.frame =CGRectMake(kWBCellPadding+(kWBCellPaddingPic +picSize.width)*row,CGRectGetMaxY(self.connectLabel.frame)+(kWBCellPaddingPic+picSize.height)*column, picSize.width, picSize.height);
                
                [self.contentView addSubview:imageView];
            }
        }
    }
}


-(void)setCardWithFrame:(UIView * )view isRetweet:(BOOL)isRetweet{
    WBPageInfo *pageInfo = isRetweet ? self.layout.status.retweetedStatus.pageInfo : self.layout.status.pageInfo;
    if(!pageInfo) return;
    
    CGFloat height = isRetweet ? self.layout.retweetCardHeight : self.layout.cardHeight;
    
    if (isRetweet) {
         self.cardBackView.frame = CGRectMake(kWBCellPadding, CGRectGetMaxY(self.RetweetLabel.frame), [UIScreen mainScreen].bounds.size.width-24, height);
         [self.RetweetBackView addSubview:self.cardBackView];
//        self.cardBackView.layer.borderColor = kWBCellHighlightColor.CGColor;
    }else{
         self.cardBackView.frame = CGRectMake(kWBCellPadding, CGRectGetMaxY(self.connectLabel.frame), kWBCellContentWidth, height);
         [self.contentView addSubview:self.cardBackView];
//        self.cardBackView.layer.borderColor = kWBCellHighlightColor.CGColor;
    }
    
    //  判断 卡片类型
    switch (isRetweet ? self.layout.retweetCardType : self.layout.cardType) {
        case WBStatusCardTypeNone:
            
            break;
        case WBStatusCardTypeNormal:{
            //            普通卡片
            self.cardTextLabel.hidden = NO;
             self.badgeImageView.hidden = NO;
            self.cardBtn.hidden = YES;
            self.cardImageView.hidden = NO;
            
            if (pageInfo.typeIcon) {
                self.badgeImageView.hidden = NO;
                self.badgeImageView.frame = CGRectMake(0, 0, 25, 25);
                [self.badgeImageView sd_setImageWithURL:pageInfo.typeIcon];
            }else{
                self.badgeImageView.hidden = YES;
            }
            if (pageInfo.pagePic) {
                self.cardImageView.hidden = NO;
                if (pageInfo.typeIcon) {
                    self.cardImageView.frame = CGRectMake(0, 0, 100, 70);
                }else{
                    self.cardImageView.frame = CGRectMake(0, 0, 70, 70);
                }
                [self.cardImageView sd_setImageWithURL:pageInfo.pagePic];
            }else{
                self.cardImageView.hidden = YES;
            }
//            文字
            self.cardTextLabel.frame = isRetweet ? self.layout.retweetCardTextRect : self.layout.cardTextRect;
            self.cardTextLabel.textLayout = isRetweet ? self.layout.retweetCardTextLayout : self.layout.cardTextLayout;
            
        }
            break;
        case WBStatusCardTypeVideo:
            self.badgeImageView.hidden = YES;
            self.cardImageView.hidden = NO;
            self.cardTextLabel.hidden = YES;
            self.cardBtn.hidden = NO;
            self.cardImageView.frame = self.cardBackView.bounds;
            [self.cardImageView sd_setImageWithURL:pageInfo.pagePic];
            
#warning 加不上播放按钮....
            self.cardBtn.frame = CGRectMake(self.cardBackView.frame.size.width/2-27, self.cardBackView.frame.size.height/2-27, 54, 54);
           
            [self.cardBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [self.cardBtn setBackgroundImage:[UIImage imageNamed:@"ResourceWeibo.bundle/multimedia_videocard_play"] forState:UIControlStateNormal];
            [self.cardImageView insertSubview:self.cardBtn aboveSubview:self.cardImageView];
            break;
        default:
            break;
    }
}


-(void)settoolView{
    self.toolView.frame =  CGRectMake(12, self.contentView.frame.size.height  - 35,kWBCellContentWidth, 35);
    self.toolView.backgroundColor = kWBCellBackgroundColor;
    
    for (UIView * view in self.toolView.subviews) {
        [view removeFromSuperview];
    }
    
    CGFloat width = kWBCellContentWidth/3.0;
    UIButton * RepostBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0,width, 35)];
    [self.toolView addSubview:RepostBtn];
//    添加一个label 和 一个图片 用富文本插进去图片
    YYLabel * ReposttextLabel = [YYLabel new];
    ReposttextLabel.textLayout = self.layout.toolbarRepostTextLayout;
    ReposttextLabel.textAlignment = NSTextAlignmentCenter;
    ReposttextLabel.frame = CGRectMake(0, 0, RepostBtn.frame.size.width, 35);
    ReposttextLabel.center = CGPointMake(RepostBtn.frame.size.width/2, ReposttextLabel.center.y);
    [RepostBtn addSubview:ReposttextLabel];
    
    
    UIButton * commentBtn = [[UIButton alloc]initWithFrame:CGRectMake(width, 0,width, 35)];
    [self.toolView addSubview:commentBtn];
    //    添加一个label 和 一个图片 用富文本插进去图片
    YYLabel * commenttextLabel = [YYLabel new];
    commenttextLabel.textLayout = self.layout.toolbarCommentTextLayout;
    commenttextLabel.textAlignment = NSTextAlignmentCenter;
    commenttextLabel.frame = CGRectMake(0, 0, commentBtn.frame.size.width, 35);
    commenttextLabel.center = CGPointMake(commentBtn.frame.size.width/2, commenttextLabel.center.y);
    [commentBtn addSubview:commenttextLabel];
    
    UIButton * likeBtn = [[UIButton alloc]initWithFrame:CGRectMake(width*2, 0,width, 35)];
    [self.toolView addSubview:likeBtn];
    //    添加一个label 和 一个图片 用富文本插进去图片
    YYLabel * liketextLabel = [YYLabel new];
    liketextLabel.textLayout = self.layout.toolbarLikeTextLayout;
    liketextLabel.textAlignment = NSTextAlignmentCenter;
    liketextLabel.frame = CGRectMake(0, 0, likeBtn.frame.size.width, 35);
    liketextLabel.center = CGPointMake(likeBtn.frame.size.width/2, liketextLabel.center.y);
    [likeBtn addSubview:liketextLabel];
    
//    分割线暂时不加
}



















@end
