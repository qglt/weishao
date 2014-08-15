/***********************************************************************************
 * This software is under the MIT License quoted below:
 ***********************************************************************************
 *
 * Copyright (c) 2010 Olivier Halligon
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 ***********************************************************************************/






#import "OHASBasicHTMLParser.h"
#import "NSAttributedString+Attributes.h"
#import "NSString+Base64.h"
#import "SmileyParser.h"

#if __has_feature(objc_arc)
#define MRC_AUTORELEASE(x) (x)
#else
#define MRC_AUTORELEASE(x) [(x) autorelease]
#endif

@implementation OHASBasicHTMLParser

NSDictionary *emotDicts =nil;

+(void)initialize {
    [super initialize];
    if (emotDicts!=nil) {
        return;
    }
    emotDicts = [SmileyParser parser].smileyTextToId;//@"吵架":@"1-10-3"
}


+(NSDictionary*)tagMappings
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            
//            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
//            {
//               
//                NSRange textRange = [match rangeAtIndex:1];
//                if (textRange.length>0)
//                {
//                    NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
//                    [foundString setTextBold:YES range:NSMakeRange(0,textRange.length)];
//                    return MRC_AUTORELEASE(foundString);
//                } else {
//                    return nil;
//                }
//            }, @"<b>(.+?)</b>",
            
//            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
//            {
//                NSRange textRange = [match rangeAtIndex:1];
//                if (textRange.length>0)
//                {
//                    NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
//                    [foundString setTextIsUnderlined:YES];
//                    return MRC_AUTORELEASE(foundString);
//                } else {
//                    return nil;
//                }
//            }, @"<u>(.+?)</u>",
            
//            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
//            {
//                NSRange fontNameRange = [match rangeAtIndex:2];
//                NSRange fontSizeRange = [match rangeAtIndex:4];
//                NSRange textRange = [match rangeAtIndex:5];
//                if ((fontNameRange.length>0) && (fontSizeRange.length>0) && (textRange.length>0))
//                {
//                    NSString* fontName = [str attributedSubstringFromRange:fontNameRange].string;
//                    CGFloat fontSize = [str attributedSubstringFromRange:fontSizeRange].string.floatValue;
//                    NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
//                    [foundString setFontName:fontName size:fontSize];
//                    return MRC_AUTORELEASE(foundString);
//                } else {
//                    return nil;
//                }
//            }, @"<font name=(['\"])(.+?)\\1 size=(['\"])(.+?)\\3>(.+?)</font>",
//            
//            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
//            {
//                NSLog(@"4---^NSAttributedString*(NSAttributedString* %@, NSTextCheckingResult* match %@)",str,match);
//                NSRange colorRange = [match rangeAtIndex:2];
//                NSRange textRange = [match rangeAtIndex:3];
//                if ((colorRange.length>0) && (textRange.length>0))
//                {
//                    NSString* colorName = [str attributedSubstringFromRange:colorRange].string;
//                    UIColor* color = OHUIColorFromString(colorName);
//                    NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
//                    [foundString setTextColor:color];
//                    return MRC_AUTORELEASE(foundString);
//                } else {
//                    return nil;
//                }
//            }, @"<font color=(['\"])(.+?)\\1>(.+?)</font>",
            
//            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
//            {
//                NSRange linkRange = [match rangeAtIndex:2];
//                NSRange textRange = [match rangeAtIndex:3];
//                if ((linkRange.length>0) && (textRange.length>0))
//                {
//                    NSString* link = [str attributedSubstringFromRange:linkRange].string;
//                    NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
//                    [foundString setLink:[NSURL URLWithString:link] range:NSMakeRange(0,textRange.length)];
//                    return MRC_AUTORELEASE(foundString);
//                } else {
//                    return nil;
//                }
//            }, @"<a href=(['\"])(.+?)\\1>(.+?)</a>",
            
//            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
//            {
//                NSLog(@"6---^NSAttributedString*(NSAttributedString* %@, NSTextCheckingResult* match %@)",str,match);
//                NSRange linkRange = [match rangeAtIndex:1];
//                NSRange textRange = [match rangeAtIndex:1];
//                if ((linkRange.length>0) && (textRange.length>0))
//                {
//                    NSLog(@"7---^NSAttributedString*(NSAttributedString* %@, NSTextCheckingResult* match %@)",str,match);
//                    NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
//                    [foundString setTextColor:[UIColor blueColor]];
//                    return MRC_AUTORELEASE(foundString);
//                } else {
//                    return nil;
//                }
//            }, @"(#[a-zA-Z0-9\\u4e00-\\u9fa5]+?#)",
            
//            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
//            {
//                NSLog(@"8---^NSAttributedString*(NSAttributedString* %@, NSTextCheckingResult* match %@)",str,match);
//                NSRange linkRange = [match rangeAtIndex:1];
//                NSRange textRange = [match rangeAtIndex:1];
//                if ((linkRange.length>0) && (textRange.length>0))
//                {
//                    NSString* link = [str attributedSubstringFromRange:linkRange].string;
//                    NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
//                    link = [link base64EncodedString];
//                    NSURL *url = [NSURL URLWithString:link];
//                    [foundString setLink:url range:NSMakeRange(0,[foundString length])];
//                    return MRC_AUTORELEASE(foundString);
//                } else {
//                    return nil;
//                }
//            }, @"(@[a-zA-Z0-9\\u4e00-\\u9fa5]+)",
//            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
//            {
//                NSLog(@"9---^NSAttributedString*(NSAttributedString* %@, NSTextCheckingResult* match %@)",str,match);
//                NSRange linkRange = [match rangeAtIndex:1];
//                NSRange textRange = [match rangeAtIndex:1];
//                if ((linkRange.length>0) && (textRange.length>0))
//                {
//                    NSString* link = [str attributedSubstringFromRange:linkRange].string;
//                    NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
//                    link = [link base64EncodedString];
//                    NSURL *url = [NSURL URLWithString:link];
//                    [foundString setLink:url range:NSMakeRange(0,[foundString length])];
//                    return MRC_AUTORELEASE(foundString);
//                } else {
//                    return nil;
//                }
//            }, @"(\\s(视频链接|微刊链接)$)",
            
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:NSMakeRange(38,str.length-44)] mutableCopy];
                return MRC_AUTORELEASE(foundString);
            }, @"<nav\\s+class=(.+?)>(.+?)</nav>",
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSRange linkRange = [match rangeAtIndex:0];
                NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:NSMakeRange(linkRange.location+3, 14)] mutableCopy];
                [foundString setFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:11.0f]];
                [foundString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
                return MRC_AUTORELEASE(foundString);
            }, @"<b>我发起了一次投票，快来参与吧</b><br>",//<nav\\s+class=(.+?)>(.+?)</nav><b>我发起了一次投票，快来参与吧</b>
            
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                
                //            <nav class='crowd_vote_info clearfix'><b>我发起了一次投票，快来参与吧</b><br><p class='crowd_note_box'>sfd</p><p class='click_crowd_vote link_font' showname='郭强3'  parent_name='C5F86196-7C70-0001-4412-1D701F4BC500' jid='24595@qa.ruijie.com.cn' gid='100005@groups.qa.ruijie.com.cn' vid='184'>点击参与</p></nav>
                NSLog(@"4---^NSAttributedString*(NSAttributedString* %@, NSTextCheckingResult* match %@)",str,match);
                NSRange linkRange = [match rangeAtIndex:0];
                NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:NSMakeRange(linkRange.location+26,linkRange.length-30)] mutableCopy];
                [foundString setFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f]];
                return MRC_AUTORELEASE(foundString);
            }, @"<p class='crowd_note_box'>(.+?)</p>",
            
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSLog(@"8---^click_crowd_vote*(NSAttributedString* %@, NSTextCheckingResult* match %@)",str,match);
                //            <nav class='crowd_vote_info clearfix'><b>我发起了一次投票，快来参与吧</b><br><p class='crowd_note_box'>sfd</p><p class='click_crowd_vote link_font' showname='郭强3'  parent_name='C5F86196-7C70-0001-4412-1D701F4BC500' jid='24595@qa.ruijie.com.cn' gid='100005@groups.qa.ruijie.com.cn' vid='184'>点击参与</p></nav>
                NSRange linkRange = [match rangeAtIndex:0];
                NSString *temp = [str attributedSubstringFromRange:linkRange].string;
                NSRange tempRange = [temp rangeOfString:@">"];
                int start =linkRange.location+tempRange.location+1;
                NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:NSMakeRange(start,linkRange.length-5-tempRange.location)] mutableCopy];
                [foundString insertAttributedString:[[NSAttributedString alloc] initWithString:@"("] atIndex:0];
                [foundString appendAttributedString:[[NSAttributedString alloc] initWithString:@")"]];
                [foundString setFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f]];
                [foundString setLink:[NSURL URLWithString:@"crowdVote"]range:NSMakeRange(0, foundString.length)];
//                [foundString add]
                return MRC_AUTORELEASE(foundString);
            }, @"<p\\s+class=(.+?)>(.+?)</p>",
            //<nav\\s+class=(.+?)>(.+?)</nav><b>我发起了一次投票，快来参与吧</b>
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
//                NSLog(@"10---^NSAttributedString*(NSAttributedString* %@, NSTextCheckingResult* match %@)",str,match);
                NSRange linkRange = [match rangeAtIndex:1];
                NSRange textRange = [match rangeAtIndex:1];
                if ((linkRange.length>0) && (textRange.length>0))
                {
                    NSString* link = [str attributedSubstringFromRange:linkRange].string;
//                    NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:NSMakeRange(0,0)] mutableCopy];
//                    [foundString setEmoit:link range:NSMakeRange(0,[foundString length])];
                    
                    
                    //render empty space for drawing the image in the text //1
                    CTRunDelegateCallbacks callbacks;
                    callbacks.version = kCTRunDelegateVersion1;
                    callbacks.getAscent = ascentCallback;
                    callbacks.getDescent = descentCallback;
                    callbacks.getWidth = widthCallback;
                    callbacks.dealloc = deallocCallback;
                    
                    NSDictionary* imgAttr = [[NSDictionary dictionaryWithObjectsAndKeys: //2
                                              @"24", @"width",
                                              @"24", @"height",
                                              @"0", @"descent",
                                              nil] retain];
                    
                    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, imgAttr); //3
                    
//                    CTFontRef sysUIFont = CTFontCreateUIFontForLanguage(kCTFontSystemFontType,
//                                                                        30.0, NULL);
                    
                    NSDictionary *attrDictionaryDelegate = [NSDictionary dictionaryWithObjectsAndKeys:
                                                            //set the delegate
                                                            (id)delegate, (NSString*)kCTRunDelegateAttributeName,
//                                                            (id)sysUIFont, (id)kCTFontAttributeName,
                                                            nil];
                    
                    CFRelease(delegate);
//                    CFRelease(sysUIFont);
                    NSMutableAttributedString* foundString = [[NSMutableAttributedString alloc] initWithString:@" " attributes:attrDictionaryDelegate];
                    
                    [foundString setEmoit:[NSString stringWithFormat:@"%@|%@|%@",emotDicts[link],// .png \\[(\\S+?)\\]
                                           imgAttr[@"width"], imgAttr[@"height"]]];
                    
                    return MRC_AUTORELEASE(foundString);
                } else {
                    return nil;
                }
            },[SmileyParser parser].OHpushPattern ,//@"\\[([a-zA-Z0-9\\u4e00-\\u9fa5]+?)\\]"
            
            nil];
}

/* Callbacks */
static void deallocCallback( void* ref ){
    [(id)ref release];
    ref = nil;
}
static CGFloat ascentCallback( void *ref ){
    return [(NSString*)[(NSDictionary*)ref objectForKey:@"height"] floatValue];
}
static CGFloat descentCallback( void *ref ){
    return [(NSString*)[(NSDictionary*)ref objectForKey:@"descent"] floatValue];
}
static CGFloat widthCallback( void* ref ){
    return [(NSString*)[(NSDictionary*)ref objectForKey:@"width"] floatValue];
}

@end


