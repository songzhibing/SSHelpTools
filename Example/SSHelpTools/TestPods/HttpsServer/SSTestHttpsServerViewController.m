//
//  SSTestHttpsServerViewController.m
//  SSTestCode
//
//  Created by 宋直兵 on 2022/10/20.
//

#import "SSTestHttpsServerViewController.h"
#import <CocoaHTTPServer/HTTPServer.h>
#import <CocoaHTTPServer/HTTPConnection.h>
#import <CocoaHTTPServer/HTTPDataResponse.h>
#import <CocoaHTTPServer/HTTPMessage.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <SSHelpWebViewController.h>

@interface YDHTTPConnection : HTTPConnection

@end

@implementation YDHTTPConnection

#pragma mark - get & post
 
- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
//    HTTPLogTrace();
    
    // Add support for POST
    if ([method isEqualToString:@"POST"])
    {
        if ([path isEqualToString:@"/calculate"])
        {
            // Let's be extra cautious, and make sure the upload isn't 5 gigs
            return YES;
        }
    }
    
    return [super supportsMethod:method atPath:path];
}
 
- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
//    HTTPLogTrace();
    
    // Inform HTTP server that we expect a body to accompany a POST request
    if([method isEqualToString:@"POST"]) return YES;
    
    return [super expectsRequestBodyFromMethod:method atPath:path];
}
 
- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
//    HTTPLogTrace();
    
    //获取idfa
    if ([path isEqualToString:@"/getIdfa"])
    {
        SSLog(@"%@[%p]: postContentLength: %qu", THIS_FILE, self, requestContentLength);
        NSString *idfa = [UIDevice ss_UUID];
        NSData *responseData = [NSJSONSerialization dataWithJSONObject:@{@"uuid":idfa} options:0 error:nil];

        return [[HTTPDataResponse alloc] initWithData:responseData];
    } else if ([path isEqualToString:@"/ChuangDa/manifest.plist"]) {
        NSString *plist = [[NSBundle mainBundle] pathForResource:@"HttpsServer/ChuangDa/manifest" ofType:@"plist"];//证书的路径 xx.cer
        NSData *data = [NSData dataWithContentsOfFile:plist];
        return [[HTTPDataResponse alloc] initWithData:data];
    } else if ([path hasPrefix:@"/ChuangDa"]) {
        path = [@"HttpsServer" stringByAppendingPathComponent:path];
        NSString *plist = [[NSBundle mainBundle] pathForResource:path.stringByDeletingPathExtension ofType:path.pathExtension];//证书的路径 xx.cer
        NSData *data = [NSData dataWithContentsOfFile:plist];
        return [[HTTPDataResponse alloc] initWithData:data];
    }
    
    //加减乘除计算
    if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/calculate"])
    {
        SSLog(@"%@[%p]: postContentLength: %qu", THIS_FILE, self, requestContentLength);
        NSData *requestData = [request body];
        NSDictionary *params = [self getRequestParam:requestData];
        NSInteger firstNum = [params[@"firstNum"] integerValue];
        NSInteger secondNum = [params[@"secondNum"] integerValue];
        NSDictionary *responsDic = @{@"add":@(firstNum + secondNum),
                                     @"sub":@(firstNum - secondNum),
                                     @"mul":@(firstNum * secondNum),
                                     @"div":@(firstNum / secondNum)};
        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responsDic options:0 error:nil];
        return [[HTTPDataResponse alloc] initWithData:responseData];
    }
    
    return [super httpResponseForMethod:method URI:path];
}
 
- (void)prepareForBodyWithSize:(UInt64)contentLength
{
    // HTTPLogTrace();
    
    // If we supported large uploads,
    // we might use this method to create/open files, allocate memory, etc.
}
 
- (void)processBodyData:(NSData *)postDataChunk
{
    // HTTPLogTrace();
    
    // Remember: In order to support LARGE POST uploads, the data is read in chunks.
    // This prevents a 50 MB upload from being stored in RAM.
    // The size of the chunks are limited by the POST_CHUNKSIZE definition.
    // Therefore, this method may be called multiple times for the same POST request.
    BOOL result = [request appendData:postDataChunk];
    if (!result)
    {
        SSLog(@"%@[%p]: %@ - Couldn't append bytes!", THIS_FILE, self, THIS_METHOD);
    }
}

#pragma mark - https
 
- (BOOL)isSecureServer
{
//    HTTPLogTrace();
    SSLog(@"isSecureServer...");

    return YES;
}
 
- (NSArray *)sslIdentityAndCertificates
{
//    HTTPLogTrace();
    SSLog(@"sslIdentityAndCertificates...");

    SecIdentityRef identityRef = NULL;
    SecCertificateRef certificateRef = NULL;
    SecTrustRef trustRef = NULL;
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"localhost" ofType:@"p12"];
    thePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"HttpsServer/server.p12"];
    
    NSData *PKCS12Data = [[NSData alloc] initWithContentsOfFile:thePath];
    CFDataRef inPKCS12Data = (__bridge CFDataRef)PKCS12Data;
    CFStringRef password = CFSTR("");//CFSTR("123456");
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    CFDictionaryRef optionsDictionary = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
 
    OSStatus securityError = errSecSuccess;
    securityError =  SecPKCS12Import(inPKCS12Data, optionsDictionary, &items);
    if (securityError == 0) {
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex (items, 0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemIdentity);
        identityRef = (SecIdentityRef)tempIdentity;
        const void *tempTrust = NULL;
        tempTrust = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemTrust);
        trustRef = (SecTrustRef)tempTrust;
    } else {
        NSLog(@"Failed with error code %d",(int)securityError);
        return nil;
    }
 
    SecIdentityCopyCertificate(identityRef, &certificateRef);
    NSArray *result = [[NSArray alloc] initWithObjects:(__bridge id)identityRef, (__bridge id)certificateRef, nil];
 
    return result;
}
 
#pragma mark - 私有方法
 
//获取上行参数
- (NSDictionary *)getRequestParam:(NSData *)rawData
{
    if (!rawData) return nil;
    
    NSString *raw = [[NSString alloc] initWithData:rawData encoding:NSUTF8StringEncoding];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSArray *array = [raw componentsSeparatedByString:@"&"];
    for (NSString *string in array) {
        NSArray *arr = [string componentsSeparatedByString:@"="];
        NSString *value = [arr.lastObject stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [paramDic setValue:value forKey:arr.firstObject];
    }
    return [paramDic copy];
}

@end

@interface SSTestHttpsServerViewController (){
    HTTPServer *httpServer;
}
@end

@implementation SSTestHttpsServerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Configure our logging framework.
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Initalize our http server
    httpServer = [[HTTPServer alloc] init];
    
    // Tell the server to broadcast its presence via Bonjour.
    [httpServer setType:@"_http._tcp."];
    
    // Normally there's no need to run our server on any specific port.
    [httpServer setPort:12345];
    
    // We're going to extend the base HTTPConnection class with our MyHTTPConnection class.
    [httpServer setConnectionClass:[YDHTTPConnection class]];
    
    // Serve files from our embedded Web folder
    NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"HttpsServer"];
    SSLog(@"Setting document root: %@", webPath);
    [httpServer setDocumentRoot:webPath];
    
    NSError *error = nil;
    if(![httpServer start:&error]) {
        SSLog(@"Error starting HTTP Server: %@", error);
    } else {
        SSLog(@"Success starting HTTP Server: %@:%td", httpServer.interface, httpServer.port);
    }
    
    
    SSHelpButton *cerBtn = [SSHelpButton buttonWithType:UIButtonTypeCustom];
    cerBtn.normalTitle = @"cer";
    cerBtn.normalTitleColor = [UIColor blueColor];
    [self.view addSubview:cerBtn];
    [cerBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(80);
        make.size.mas_equalTo(CGSizeMake(100, 44));
    }];
    [cerBtn setOnClick:^(SSHelpButton * _Nonnull sender) {
        SSHelpWebViewController *web = [[SSHelpWebViewController alloc] init];
        web.indexString = @"https://localhost:12345/index.html";
        [self.navigationController pushViewController:web animated:YES];
    }];
    
    
    SSHelpButton *installIpaBtn = [SSHelpButton buttonWithType:UIButtonTypeCustom];
    installIpaBtn.normalTitle = @"安装";
    installIpaBtn.normalTitleColor = [UIColor blueColor];
    [self.view addSubview:installIpaBtn];
    [installIpaBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cerBtn.mas_bottom).offset(10);
        make.left.mas_equalTo(cerBtn);
        make.size.mas_equalTo(CGSizeMake(100, 44));
    }];
    [installIpaBtn setOnClick:^(SSHelpButton * _Nonnull sender) {
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager] initWithBaseURL:[NSURL URLWithString:@"https://localhost:12345/"]];
        //AFSSLPinningModeCertificate模式与AFSSLPinningModePublicKey模式都会加载项目中所有的.cer后缀的证书文件来进行校验。AFSecurityPolicy需要使用一下方法创建。
        manager.securityPolicy = [self customSecurityPolicy];
//        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];

        //允许使用无效证书(自建证书)
//        manager.securityPolicy.allowInvalidCertificates = YES;//默认NO
        //不需要域名验证
//        manager.securityPolicy.validatesDomainName = NO;//默认YES
        [manager GET:@"https://localhost:12345/install" parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //
        }];
//        [manager GET:@"https://127.0.0.1:3000" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
//
//        NSLog(@"%@",responseObject);
//
//        //将打印：hi : 'Hello World!', hello : 'Hello Node!'字典
//
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//        }];
    }];
}


- (AFSecurityPolicy *)customSecurityPolicy {
    
    // 先导入证书 证书由服务端生成，具体由服务端人员操作
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"cert_ios" ofType:@"cer"];//证书的路径 xx.cer
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    
    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    
    //validatesDomainName 是否需要验证域名，默认为YES;
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = NO;
    
    securityPolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:cerData, nil];
    return securityPolicy;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
