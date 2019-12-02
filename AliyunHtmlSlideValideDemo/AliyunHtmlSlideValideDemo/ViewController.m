//
//  ViewController.m
//  AliyunHtmlSlideValideDemo
//
//  Created by cgw on 2019/12/2.
//  Copyright © 2019 bill. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@protocol JSObjcDelegate;

/**
 阿里云Html滑块验证 （人机验证）
 */
@interface ViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    self.webView.hidden = NO;
//    self.view.backgroundColor = [UIColor redColor];
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.webView.scrollView.backgroundColor = [UIColor redColor];
    self.webView.frame = CGRectMake(0, 0, size.width, 100);
    self.webView.scrollView.bounces = NO;
    self.webView.center = self.view.center;
    
    [self loadLocalHtmlForJs];
}

- (void)loadLocalHtmlForJs{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"slide" ofType:@"html"];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
    [self.webView loadRequest:req];
}

-(void)loadHtmlWithHtmlName:(NSString*)htmlName webView:(WKWebView*)webView{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:htmlName ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:filePath]];
}

- (void)getSlideData:(NSDictionary *)callData {
//{"token":nc_token,"sid":data.csessionid,"sig":data.sig}
    NSLog(@"Get:%@", callData);
}


#pragma mark - WebViewUIDelegate

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    NSDictionary *para = message.body;
    if( [para isKindOfClass:[NSDictionary class]] ==NO ){
        [self getSlideData:nil];
        return;
    }
//    {"token":nc_token,"sid":data.csessionid,"sig":data.sig}
//    NSString *stringData = para[@"stringData"];
    //    NSString *boolData = para[@"boolData"];
    
    __weak typeof(self ) weakSelf = self;
    if ([message.name isEqualToString:@"successCallback"]) {
        NSLog(@"Add NavigationBar");
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf getSlideData:para];
        });
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    //    DLOG(@"msg = %@ frmae = %@",message,frame);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSLog(@"sssss");
    decisionHandler(WKNavigationResponsePolicyAllow);
}


#pragma mark - getter
- (WKWebView *)webView {
    if( !_webView ){
        
        //进行配置控制器
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        //实例化对象
        configuration.userContentController = [WKUserContentController new];
        [configuration.userContentController addScriptMessageHandler:self name:@"successCallback"];
        
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        configuration.preferences = preferences;
        
        CGFloat iy = 0;
        CGSize size = self.view.frame.size;
        CGRect frame = CGRectMake(0, iy, size.width, size.height-iy);
        _webView = [[WKWebView alloc] initWithFrame:frame configuration:configuration];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        [self.view addSubview:_webView];
    }
    
    return _webView;
}

@end
