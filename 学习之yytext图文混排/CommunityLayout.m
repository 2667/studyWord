//
//  CommunityLayout.m
//  学习之yytext图文混排
//
//  Created by huochaihy on 16/10/19.
//  Copyright © 2016年 CHL. All rights reserved.
//

#import "CommunityLayout.h"
#import "NSAttributedString+YYText.h"
#import "UIImageView+WebCache.h"

@implementation CommunityLayout

- (instancetype)initWithStatus:(WBStatus *)status style:(WBLayoutStyle)style {
    if (!status || !status.user) return nil;
    self = [super init];
    _status = status;
    _style = style;
    [self layout];
    return self;
}


-(void)layout{
    

    _titleHeight = 0; // 标题
    _profileHeight = 0; //个人信息
    _textHeight = 0; // 文本
    _picHeight = 0; // 图片
    _toolbarHeight = kWBCellToolbarHeight; //工具
    _marginBottom = kWBCellToolbarBottomMargin; // 底部留白
    _cardHeight = 0;
    _retweetCardHeight = 0;
    _retweetHeight = 0;
    
    [self layoutProfile];
//    转发
    [self layoutRetweetedText];
    
    if (_retweetHeight == 0) {
        
        [self layoutPicsWithStatus:_status isRetweet:NO];
        
        if (_picHeight == 0) {
            [self layoutCardWithStatus:_status isRetweet:NO];
        }
    }
    
    
    //    布局文本
    [self layoutText];
    
    [self layoutToolView];
    
    // 计算高度
    _height = 0;
    _height += _titleHeight;
    _height += _profileHeight;
    _height += _textHeight;
    if (_retweetHeight > 0) {
        _height += _retweetHeight;
    } else if (_picHeight > 0) {
        _height += _picHeight;
    } else if (_cardHeight > 0) {
        _height += _cardHeight;
    }
    _height += _toolbarHeight;
    _height += _marginBottom;
}

//- (void)_layoutTitle {
//    _titleHeight = 0;
//    _titleTextLayout = nil;
//    
//    WBStatusTitle *title = _status.title;
//    if (title.text.length == 0) return;
//    
//    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:title.text];
//    if (title.iconURL) {
//        UIImage * image = [[[UIImageView alloc]init] sd_setImageWithURL:];
//       NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent: contentMode:UIViewContentModeCenter attachmentSize:[UIImageView ].size alignToFont:[UIFont systemFontOfSize:15] alignment:YYTextVerticalAlignmentCenter];
//        
//        if (icon) {
//            [text insertAttributedString:icon atIndex:0];
//        }
//    }
//    text.yy_color = kWBCellToolbarTitleColor;
//    text.yy_font = [UIFont systemFontOfSize:kWBCellTitlebarFontSize];
//    
//    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(kScreenWidth - 100, kWBCellTitleHeight)];
//    _titleTextLayout = [YYTextLayout layoutWithContainer:container text:text];
//    _titleHeight = kWBCellTitleHeight;
//}

-(void)layoutProfile{
    //    布局个人资料
    
    //    名字
    WBUser * user = _status.user;
    NSString * nameString = nil;
    //    首先判断是否有备注
    if (user.remark.length>0) {
        nameString = user.remark;
    }else{
        nameString = user.screenName;
    }
    
    if (nameString.length == 0) {
        _nameTextLayout = nil;
        return;
    }
    
    NSMutableAttributedString * nameAttributedString = [[NSMutableAttributedString alloc]initWithString:nameString];
    
    //    再确定是否为VIP
    if (user.mbrank >0) {
        //        有VIP 需要显示图片 可用到富文本图片  这里先用yytext
        UIImage * yellowVImage = [UIImage imageNamed:[NSString stringWithFormat:@"ResourceWeibo.bundle/common_icon_membership_level%d",user.mbrank]];
        if (!yellowVImage) {
            yellowVImage = [UIImage imageNamed:@"ResourceWeibo.bundle/common_icon_membership.png"];
        }
        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:yellowVImage contentMode:UIViewContentModeCenter attachmentSize:yellowVImage.size alignToFont:[UIFont systemFontOfSize:kWBCellNameFontSize] alignment:YYTextVerticalAlignmentCenter];
        [nameAttributedString insertAttributedString:attachText atIndex:nameAttributedString.string.length];
    }
    
    nameAttributedString.yy_font = [UIFont systemFontOfSize:kWBCellNameFontSize];
    nameAttributedString.yy_color = user.mbrank>0?kWBCellNameOrangeColor:kWBCellNameNormalColor;
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(kWBCellNameWidth, MAXFLOAT)];
    container.maximumNumberOfRows = 1;
    _nameTextLayout = [YYTextLayout layoutWithContainer:container text:nameAttributedString];
   
    
//    时间、来源
//    时间
    NSMutableAttributedString *sourceText = [NSMutableAttributedString new];
    NSString *createTime = [self StringWithTimeLineDate:_status.createdAt];
    if (createTime.length) {
        NSMutableAttributedString *timeText = [[NSMutableAttributedString alloc] initWithString:createTime];
        timeText.yy_font = [UIFont systemFontOfSize:kWBCellSourceFontSize];
        timeText.yy_color = kWBCellTimeNormalColor;
        [sourceText appendAttributedString:timeText];
    }
    
//    来源
    if (_status.source.length) {
        // <a href="sinaweibo://customweibosource" rel="nofollow">iPhone 5siPhone 5s</a>
//        去读出关键的字段
        NSRegularExpression *hrefRegex, *textRegex;
        hrefRegex = [NSRegularExpression regularExpressionWithPattern:@"(?<=href=\").+(?=\" )" options:kNilOptions error:NULL];
        textRegex = [NSRegularExpression regularExpressionWithPattern:@"(?<=>).+(?=<)" options:kNilOptions error:NULL];
        
        NSTextCheckingResult *hrefResult, *textResult;
        NSString *href = nil, *text = nil;
        hrefResult = [hrefRegex firstMatchInString:_status.source options:kNilOptions range:NSMakeRange(0, _status.source.length)];
        textResult = [textRegex firstMatchInString:_status.source options:kNilOptions range:NSMakeRange(0, _status.source.length)];
        
        href = [_status.source substringWithRange:hrefResult.range];
        text = [_status.source substringWithRange:textResult.range];
//
        if (href.length && text.length) {
            NSMutableAttributedString * from = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@" 来自 %@",text]];
            from.yy_font = [UIFont systemFontOfSize:kWBCellSourceFontSize];
            from.yy_color = kWBCellTimeNormalColor;
            
            if (_status.sourceAllowClick > 0) {
//                设置一个高亮 可点击的
//                首先将“来自 ”区分出来
                NSRange range = NSMakeRange(4, text.length);
                 [from yy_setColor:kWBCellTextHighlightColor range:range];
                YYTextBackedString *backed = [YYTextBackedString stringWithString:href];
                [from yy_setTextBackedString:backed range:range];
//                设置点击是的选中的一个高亮的变化
                YYTextBorder *border = [YYTextBorder new];
                border.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
                border.fillColor = kWBCellTextHighlightBackgroundColor;
                border.cornerRadius = 3;
//                设置高亮的点击
                YYTextHighlight *highlight = [YYTextHighlight new];
                if (href) highlight.userInfo = @{kWBLinkHrefName : href};
                [highlight setBackgroundBorder:border];
                highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
                    NSLog(@"GGGG");
                };
                [from yy_setTextHighlight:highlight range:range];
            }
            [sourceText appendAttributedString:from];
        }
    }
    
    if (sourceText.length == 0) {
        _sourceTextLayout = nil;
    } else {
        YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(kWBCellNameWidth, 9999)];
        container.maximumNumberOfRows = 1;
        _sourceTextLayout = [YYTextLayout layoutWithContainer:container text:sourceText];
    }
    
    _profileHeight = kWBCellProfileHeight;
}

-(void)layoutText{
    _titleHeight = 0.0;
    _titleTextLayout = nil;
    
    if (!_status) return;
    
    NSMutableAttributedString *text = [self textWithStatus:_status isRetweet:NO fontSize:kWBCellTextFontSize textColor:kWBCellTextNormalColor];

    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(kWBCellContentWidth, MAXFLOAT)];

    _titleTextLayout = [YYTextLayout layoutWithContainer:container text:text];
    
    _titleHeight =  _titleTextLayout.lines.count * (text.yy_font.pointSize + text.yy_lineSpacing*2);
}

-(void)layoutRetweetedText{
//    分为两个部分 一部分是文字 一部分是图片
    _retweetHeight = 0;
    _retweetTextLayout = nil;
//    _retweetCardHeight = 0;
//    _retweetPicHeight = 0;
    
    if (!_status) return;
    
    NSMutableAttributedString *text = [self textWithStatus:_status.retweetedStatus isRetweet:YES fontSize:kWBCellTextFontRetweetSize textColor:kWBCellTextSubTitleColor];
    
    [self layoutPicsWithStatus:_status.retweetedStatus isRetweet:YES];
    
    if (_retweetPicHeight == 0) {
        [self layoutCardWithStatus:_status.retweetedStatus isRetweet:YES];
    }
    
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(kWBCellContentWidth, 1000000)];
    
    _retweetTextLayout = [YYTextLayout layoutWithContainer:container text:text];
    _retweetTextHeight =  _retweetTextLayout.lines.count * (text.yy_font.pointSize + text.yy_lineSpacing*2);
    
    _retweetHeight = _retweetTextHeight+_retweetPicHeight+_retweetCardHeight;
}

-(NSString *)StringWithTimeLineDate:(NSDate *)date{
//    对时间进行处理
    
    if (!date) {
        return @"";
    }
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
//    判断
//    获取到现在的时间
    NSDate * now = [NSDate date];
    NSTimeInterval delta = now.timeIntervalSince1970 - date.timeIntervalSince1970; //如果发布的时间比现在的时间小 ，代表本地时间有问题
    if (delta < 0) {
//        直接返回
        formatter.dateFormat = @"yyyy-MM-dd";
        return [formatter stringFromDate:date];
    }else{
//        时间正常
        if(delta < 60*10 & delta > 0){//小于10分钟 显示刚刚
            return @"刚刚";
        }else if(delta < 60 * 60){//小于1个小时
            return [NSString stringWithFormat:@"%d分钟前",(int)(delta/60.0)];
        }else if(delta <= 60*60*24){ //一天内
            return [NSString stringWithFormat:@"%d小时前",(int)(delta/60.0/60.0)];
        }else if(delta >= 60*60*24 && delta <= 60*60*48){ //昨天
            formatter.dateFormat = @"昨天 HH:mm";
            return [formatter stringFromDate:date];
        }else if(delta >= 60*60*48 && delta <= 60*60*356){//1年内
            formatter.dateFormat = @"MM-dd";
            return [formatter stringFromDate:date];
        }else{
            formatter.dateFormat = @"yyyy-MM-dd";
            return [formatter stringFromDate:date];
        }
    }
}

-(NSMutableAttributedString *)textWithStatus:(WBStatus *)status
                                    isRetweet:(BOOL)isRetweet
                                     fontSize:(CGFloat)fontSize
                                   textColor:(UIColor *)textColor{
    if (!_status) return nil;
//    获取内容
    NSMutableString * mutstring = status.text.mutableCopy;
    if (mutstring.length == 0) {
        return nil;
    }
    
//    判断是否为转发和原创
    if (isRetweet) {
//        是转发的
        if (isRetweet) {
            NSString *name = status.user.name;
            if (name.length == 0) {
                name = status.user.screenName;
            }
            if (name) {
                NSString *insert = [NSString stringWithFormat:@"@%@:",name];
                [mutstring insertString:insert atIndex:0];
            }
        }
    }
    
    UIFont * font = [UIFont systemFontOfSize:fontSize];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:mutstring];
    text.yy_font = font;
    text.yy_color = textColor;
    text.yy_lineSpacing = 6;
    
    // 根据 urlStruct 中每个 URL.shortURL 来匹配文本，将其替换为图标+友好描述
    for (WBURL *wburl in status.urlStruct) {
        if (wburl.shortURL.length == 0) continue;
        if (wburl.urlTitle.length == 0) continue;
        NSString *urlTitle = wburl.urlTitle;
        if (urlTitle.length > 27) {
            urlTitle = [[urlTitle substringToIndex:27] stringByAppendingString:YYTextTruncationToken];
        }
        NSRange searchRange = NSMakeRange(0, text.string.length);
        do {
            NSRange range = [text.string rangeOfString:wburl.shortURL options:kNilOptions range:searchRange];
            if (range.location == NSNotFound) break;
            
            if (range.location + range.length == text.length) {
                if (status.pageInfo.pageID && wburl.pageID &&
                    [wburl.pageID isEqualToString:status.pageInfo.pageID]) {
                    if ((!isRetweet && !status.retweetedStatus) || isRetweet) {
                        if (status.pics.count == 0) {
                            [text replaceCharactersInRange:range withString:@""];
                            break; // cut the tail, show with card
                        }
                    }
                }
            }
            
            if ([text yy_attribute:YYTextHighlightAttributeName atIndex:range.location] == nil) {
                
                // 替换的内容
                NSMutableAttributedString *replace = [[NSMutableAttributedString alloc] initWithString:urlTitle];
                if (wburl.urlTypePic.length) {
                    // 链接头部有个图片附件 (要从网络获取)
                    UIImageView *imageView = [[UIImageView alloc ]init];
                    [imageView sd_setImageWithURL:[NSURL URLWithString:wburl.urlTypePic]];
                    
                     NSMutableAttributedString *pic = [NSMutableAttributedString yy_attachmentStringWithContent:imageView.image contentMode:UIViewContentModeCenter attachmentSize:imageView.image.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
                    [replace insertAttributedString:pic atIndex:0];
                }
                replace.yy_font = font;
                replace.yy_color = kWBCellTextHighlightColor;
                
                // 高亮状态的背景
                YYTextBorder *highlightBorder = [YYTextBorder new];
                highlightBorder.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
                highlightBorder.cornerRadius = 3;
                highlightBorder.fillColor = kWBCellTextHighlightBackgroundColor;
                
                // 高亮状态
                YYTextHighlight *highlight = [YYTextHighlight new];
                [highlight setBackgroundBorder:highlightBorder];
                // 数据信息，用于稍后用户点击
                highlight.userInfo = @{kWBLinkURLName : wburl};
                [replace yy_setTextHighlight:highlight range:NSMakeRange(0, replace.length)];
                highlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
                    NSLog(@"哈哈哈哈");
                };
                // 添加被替换的原始字符串，用于复制
                YYTextBackedString *backed = [YYTextBackedString stringWithString:[text.string substringWithRange:range]];
                [replace yy_setTextBackedString:backed range:NSMakeRange(0, replace.length)];
                
                // 替换
                [text replaceCharactersInRange:range withAttributedString:replace];
                
                searchRange.location = searchRange.location + (replace.length ? replace.length : 1);
                if (searchRange.location + 1 >= text.length) break;
                searchRange.length = text.length - searchRange.location;
            } else {
                searchRange.location = searchRange.location + (searchRange.length ? searchRange.length : 1);
                if (searchRange.location + 1>= text.length) break;
                searchRange.length = text.length - searchRange.location;
            }
        } while (1);
    }
    
    
    [self lightWith:text];
    
 

    return text;
}


-(void)layoutPicsWithStatus:(WBStatus *)Status isRetweet:(BOOL)isRetweet{
    if (isRetweet) {
        _retweetPicSize = CGSizeZero;
        _retweetPicHeight = 0;
    } else {
        _picSize = CGSizeZero;
        _picHeight = 0;
    }
    
    if (Status.pics.count == 0) {
        return;
    }
    
    CGSize picSize = CGSizeZero;
    CGFloat picHeight = 0;
    
//    排3张的大小
    CGFloat width = (kWBCellContentWidth - 2 * kWBCellPaddingPic) / 3;
    
    switch (Status.pics.count) {
        case 1:{
                WBPicture *pic = _status.pics.firstObject;
                WBPictureMetadata *bmiddle = pic.bmiddle;
                if (pic.keepSize || bmiddle.width < 1 || bmiddle.height < 1) {
//                    固定宽高
                    CGFloat maxLen = (kWBCellContentWidth) / 2.0;
                    picSize = CGSizeMake(maxLen, maxLen);
                    picHeight = maxLen;
                } else {
//                    适应宽高
                    CGFloat maxLen = width * 2 + kWBCellPaddingPic;
                    if (bmiddle.width < bmiddle.height) {
                        picSize.width = (float)bmiddle.width / (float)bmiddle.height * maxLen;
                        picSize.height = maxLen;
                    } else {
                        picSize.width = maxLen;
                        picSize.height = (float)bmiddle.height / (float)bmiddle.width * maxLen;
                    }
                    picHeight = picSize.height;
                }
        }
            break;
        case 2: case 3:{
            picSize.width = width;
            picSize.height = width;
            picHeight = width;
        }
            break;
        case 4: case 5: case 6:{
            picSize.width = width;
            picSize.height = width;
            picHeight = width*2+kWBCellPaddingPic;
        }
            break;
        case 7: case 8: case 9:{
            picSize.width = width;
            picSize.height = width;
            picHeight = width*3+kWBCellPaddingPic*2;
        }
            break;
        default:
            break;
    }
    
    if (isRetweet) {
        _retweetPicSize = picSize;
        _retweetPicHeight = picHeight;
    
    } else {
        _picSize = picSize;
        _picHeight = picHeight;
        
    }
}

-(void)layoutCardWithStatus:(WBStatus *)status isRetweet:(BOOL)isRetweet
{
//    用最常见的card
//    初始化高度 以及 卡片type
    
    if (isRetweet) {
        _retweetCardType = WBStatusCardTypeNone;
        _retweetCardHeight = 0;
        _retweetCardTextLayout = nil;
        _retweetCardTextRect = CGRectZero;
    } else {
        _cardType = WBStatusCardTypeNone;
        _cardHeight = 0;
        _cardTextLayout = nil;
        _cardTextRect = CGRectZero;
       
    }
//    获取到卡片的类型  去布局
    WBPageInfo *pageInfo = status.pageInfo;
    if (!pageInfo) return;
    
    WBStatusCardType cardType = WBStatusCardTypeNone;
    CGFloat cardHeight = 0;
    YYTextLayout *cardTextLayout = nil;
    CGRect textRect = CGRectZero;
    
    if (pageInfo.type == 11 && [pageInfo.objectType isEqualToString:@"video"]) {
//        视频的卡片模式
        cardType = WBStatusCardTypeVideo;
//      给每一个的高度
        cardHeight = (2 * kWBCellContentWidth - kWBCellPaddingPic) / 3.0;
    }else{
//        普通模式
//        一部分是图片、一部分是文字
        BOOL hasImage = pageInfo.pagePic != nil;
        BOOL hasBadge = pageInfo.typeIcon != nil;
        
        WBButtonLink *button = pageInfo.buttons.firstObject;
        BOOL hasButtom = button.pic && button.name;
        
        /*
         badge: 25,25 左上角 (42)
         image: 70,70 方形
         100, 70 矩形
         btn:  60,70
         
         lineheight 20
         padding 10
         */
//        文字高度确定为70
        textRect.size.height = kWBCellCardHeight;
        if (hasImage) {
            if (hasBadge) {
//                偏移 100
                textRect.origin.x = 100;
            }else{
                textRect.origin.x = 70;
            }
        }else{
            if (hasBadge) {
                textRect.origin.x = 42;
            }
        }
        
        textRect.origin.x += 10;
//        确定宽度
        textRect.size.width = kWBCellContentWidth-textRect.origin.x;

        if (hasButtom) textRect.size.width -= 60;
        textRect.size.width -= 10; //padding
//        设置内容
        NSMutableAttributedString * text = [[NSMutableAttributedString alloc]init];
        if (pageInfo.pageTitle) {
//            有标题 加上标题
            NSMutableAttributedString * title = [[NSMutableAttributedString alloc]initWithString:pageInfo.pageTitle];
            title.yy_font = [UIFont systemFontOfSize:kWBCellCardTitleFontSize];
            title.yy_color = kWBCellTextSubTitleColor;
            [text appendAttributedString:title];
        }
        /**
         *   添加内容 同时换行 最大行数为3行
         */
        if (pageInfo.pageDesc.length) {
            if (text.length) [text yy_appendString:@"\n"];
            NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:pageInfo.pageDesc];
            desc.yy_font = [UIFont systemFontOfSize:kWBCellCardDescFontSize];
            desc.yy_color = kWBCellTextSubTitleColor;
            [text appendAttributedString:desc];
        } else if (pageInfo.content2.length) {
            if (text.length) [text yy_appendString:@"\n"];
            NSMutableAttributedString *content3 = [[NSMutableAttributedString alloc] initWithString:pageInfo.content2];
            content3.yy_font = [UIFont systemFontOfSize:kWBCellCardDescFontSize];
            content3.yy_color = kWBCellTextSubTitleColor;
            [text appendAttributedString:content3];
        } else if (pageInfo.content3.length) {
            if (text.length) [text yy_appendString:@"\n"];
            NSMutableAttributedString *content3 = [[NSMutableAttributedString alloc] initWithString:pageInfo.content3];
            content3.yy_font = [UIFont systemFontOfSize:kWBCellCardDescFontSize];
            content3.yy_color = kWBCellTextSubTitleColor;
            [text appendAttributedString:content3];
        }
        
        if (pageInfo.tips.length) {
            if (text.length) [text yy_appendString:@"\n"];
            NSMutableAttributedString *tips = [[NSMutableAttributedString alloc] initWithString:pageInfo.tips];
            tips.yy_font = [UIFont systemFontOfSize:kWBCellCardDescFontSize];
            tips.yy_color = kWBCellTextSubTitleColor;
            [text appendAttributedString:tips];
        }
        
        if (text.length) {
            text.yy_maximumLineHeight = 20;
            text.yy_minimumLineHeight = 20;
            text.yy_lineBreakMode = NSLineBreakByTruncatingTail;
            
            YYTextContainer *container = [YYTextContainer containerWithSize:textRect.size];
            container.maximumNumberOfRows = 3;
            cardTextLayout = [YYTextLayout layoutWithContainer:container text:text];
        }
        
        if (cardTextLayout) {
            cardType = WBStatusCardTypeNormal;
            cardHeight = 70;
        }
    }
    
    if (isRetweet) {
        _retweetCardType = cardType;
        _retweetCardHeight = cardHeight;
        _retweetCardTextLayout = cardTextLayout;
        _retweetCardTextRect = textRect;

    } else {
        _cardType = cardType;
        _cardHeight = cardHeight;
        _cardTextLayout = cardTextLayout;
        _cardTextRect = textRect;
    }
}


-(void)layoutToolView{
//   把数据label 的layout 算出来
    UIFont * font = [UIFont systemFontOfSize:kWBCellToolbarFontSize];
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, kWBCellToolbarHeight)];
    container.maximumNumberOfRows = 1;
  
    NSMutableAttributedString *repostText = [[NSMutableAttributedString alloc] initWithString:_status.repostsCount <= 0 ? @"转发" : [NSString stringWithFormat:@"%zd",_status.repostsCount]];
    repostText.yy_font = font;
    repostText.yy_color = kWBCellToolbarTitleColor;
    UIImage * repostsImage = [UIImage imageNamed:@"ResourceWeibo.bundle/timeline_icon_retweet"];
    NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:repostsImage contentMode:UIViewContentModeCenter attachmentSize:repostsImage.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    [repostText insertAttributedString:attachText atIndex:0];
    
    _toolbarRepostTextLayout = [YYTextLayout layoutWithContainer:container text:repostText];
    _toolbarRepostTextWidth = _toolbarRepostTextLayout.textBoundingRect.size.width;
    
    NSMutableAttributedString *commentText = [[NSMutableAttributedString alloc] initWithString:_status.commentsCount <= 0 ? @"评论" : [NSString stringWithFormat:@"%zd",_status.commentsCount]];
    commentText.yy_font = font;
    commentText.yy_color = kWBCellToolbarTitleColor;
    
    UIImage * commentImage = [UIImage imageNamed:@"ResourceWeibo.bundle/timeline_icon_comment"];
    NSMutableAttributedString *attachText1 = [NSMutableAttributedString yy_attachmentStringWithContent:commentImage contentMode:UIViewContentModeCenter attachmentSize:commentImage.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    [commentText insertAttributedString:attachText1 atIndex:0];
    
    _toolbarCommentTextLayout = [YYTextLayout layoutWithContainer:container text:commentText];
    _toolbarCommentTextWidth = _toolbarCommentTextLayout.textBoundingRect.size.width;
    
    NSMutableAttributedString *likeText = [[NSMutableAttributedString alloc] initWithString:_status.attitudesCount <= 0 ? @"赞" :  [NSString stringWithFormat:@"%zd",_status.attitudesCount]];
    likeText.yy_font = font;
    likeText.yy_color = _status.attitudesStatus ? kWBCellToolbarTitleHighlightColor : kWBCellToolbarTitleColor;
    
     UIImage * likeImage = nil;
    if (_status.attitudesStatus) {
        likeImage = [UIImage imageNamed:@"ResourceWeibo.bundle/timeline_icon_like"];
    }else{
        likeImage = [UIImage imageNamed:@"ResourceWeibo.bundle/timeline_icon_unlike"];
    }
    NSMutableAttributedString *attachText2 = [NSMutableAttributedString yy_attachmentStringWithContent:likeImage contentMode:UIViewContentModeCenter attachmentSize:likeImage.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    [likeText insertAttributedString:attachText2 atIndex:0];
    
    _toolbarLikeTextLayout = [YYTextLayout layoutWithContainer:container text:likeText];
    _toolbarLikeTextWidth = _toolbarLikeTextLayout.textBoundingRect.size.width;
    
}














































-(void)lightWith:(NSMutableAttributedString *)one{
    
    NSArray<NSTextCheckingResult *> *atResults = [[self regexAt] matchesInString:one.string options:kNilOptions range:NSMakeRange(0, one.string.length)];
    for (NSTextCheckingResult *at in atResults) {
        if (at.range.location == NSNotFound && at.range.length <= 1) continue;
        
        __block BOOL containsBindingRange = NO;
        [one enumerateAttribute:YYTextBindingAttributeName inRange:at.range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
            if (value) {
                containsBindingRange = YES;
                *stop = YES;
            }
        }];
        if (containsBindingRange) continue;
        
        
        [one yy_setTextHighlightRange:at.range
                                color:[UIColor colorWithRed:0.093 green:0.492 blue:1.000 alpha:1.000]
                      backgroundColor:[UIColor colorWithWhite:0.000 alpha:0.220]
                            tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
                                NSLog(@"hahah");
                            }];
    }
    
    NSArray<NSTextCheckingResult *> *atResults1 = [[self regexUrl] matchesInString:one.string options:kNilOptions range:NSMakeRange(0, one.string.length)];
    for (NSTextCheckingResult *at in atResults1) {
        if (at.range.location == NSNotFound && at.range.length <= 1) continue;
        
        __block BOOL containsBindingRange = NO;
        [one enumerateAttribute:YYTextBindingAttributeName inRange:at.range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
            if (value) {
                containsBindingRange = YES;
                *stop = YES;
            }
        }];
        if (containsBindingRange) continue;
        
        
        [one yy_setTextHighlightRange:at.range
                                color:[UIColor colorWithRed:0.093 green:0.492 blue:1.000 alpha:1.000]
                      backgroundColor:[UIColor colorWithWhite:0.000 alpha:0.220]
                            tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
                                NSLog(@"hahah");
                            }];
    }
    
    NSArray<NSTextCheckingResult *> *atResults2 = [[self regexHuati] matchesInString:one.string options:kNilOptions range:NSMakeRange(0, one.string.length)];
    for (NSTextCheckingResult *at in atResults2) {
        if (at.range.location == NSNotFound && at.range.length <= 1) continue;
        
        __block BOOL containsBindingRange = NO;
        [one enumerateAttribute:YYTextBindingAttributeName inRange:at.range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
            if (value) {
                containsBindingRange = YES;
                *stop = YES;
            }
        }];
        if (containsBindingRange) continue;
        
        
        [one yy_setTextHighlightRange:at.range
                                color:[UIColor colorWithRed:0.093 green:0.492 blue:1.000 alpha:1.000]
                      backgroundColor:[UIColor colorWithWhite:0.000 alpha:0.220]
                            tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
                                NSLog(@"hahah");
                            }];
    }
}

//@
-(NSRegularExpression *)regexAt {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 微博的 At 只允许 英文数字下划线连字符，和 unicode 4E00~9FA5 范围内的中文字符，这里保持和微博一致。。
        // 目前中文字符范围比这个大
        regex = [NSRegularExpression regularExpressionWithPattern:@"@[-_a-zA-Z0-9\u4E00-\u9FA5]+" options:kNilOptions error:NULL];
    });
    return regex;
}
//url
-(NSRegularExpression *)regexUrl {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)" options:kNilOptions error:NULL];
    });
    return regex;
}
//话题
-(NSRegularExpression *)regexHuati {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"#[^@#]+?#" options:kNilOptions error:NULL];
    });
    return regex;
}
//暂时不做
//表情
-(NSRegularExpression *)regexEmoticon {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"\\[[^ \\[\\]]+?\\]" options:kNilOptions error:NULL];
    });
    return regex;
}



@end

