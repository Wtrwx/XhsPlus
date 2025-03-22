#import <UIKit/UIKit.h>

@interface XhsSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

+ (void)showSettings;

@end

@implementation XhsSettingsViewController {
    UITableView *_tableView; 
    NSArray *options;
}

static XhsSettingsViewController *instance = nil;

+ (void)showSettings {
    if (instance == nil) {
        instance = [[XhsSettingsViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:instance];
        navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        
        if (@available(iOS 13.0, *)) {
            // For iOS 13 and later
            UIWindowScene *windowScene = (UIWindowScene *)UIApplication.sharedApplication.connectedScenes.allObjects.firstObject;
            UIWindow *mainWindow = windowScene.windows.firstObject;
            if (mainWindow) {
                UIViewController *rootViewController = mainWindow.rootViewController;
                [rootViewController presentViewController:navigationController animated:YES completion:nil];
            }
        } else {
            // For iOS 12 and earlier
            UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
            if (mainWindow) {
                UIViewController *rootViewController = mainWindow.rootViewController;
                [rootViewController presentViewController:navigationController animated:YES completion:nil];
            }
        }
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupOptions];
    
    // 设置导航控制器的代理
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    
    // 添加左侧滑动手势
    UIScreenEdgePanGestureRecognizer *gestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    gestureRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (void)dismissSettingsAndResetInstance {
    [self dismissViewControllerAnimated:YES completion:^{
        instance = nil;
    }];
}

- (void)handleSwipeGesture:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // 手势开始，返回上一页
        [self dismissSettingsAndResetInstance];
    }
}

- (void)setupOptions {
    options = @[
        @{@"title": @"去除底栏购物", @"key": @"remove_tab_shopping"},
        @{@"title": @"去除底栏加号", @"key": @"remove_tab_post"},
        @{@"title": @"去除保存水印", @"key": @"remove_save_watermark"},
        @{@"title": @"强制保存媒体", @"key": @"force_save_media"}
    ];
}

- (void)setupUI {
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }

    self.navigationItem.title = @"小红书+";

    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"结束进程" style:UIBarButtonItemStylePlain target:self action:@selector(killProcess)];
    [leftButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor redColor]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = leftButtonItem;

    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭窗口" style:UIBarButtonItemStylePlain target:self action:@selector(dismissSettings)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;

    [self setupTableView];
}

- (void)setupTableView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2; // 设置和关于两个部分
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return options.count;
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

    if (indexPath.section == 0) {
        NSDictionary *option = options[indexPath.row];
        cell.textLabel.text = option[@"title"];
        
        // 创建一个透明的 UIButton 用于拦截点击事件
        UIButton *button = [UIButton buttonWithType:UIButtonTypeXhs];
        button.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
        [button addTarget:self action:@selector(optionTapped:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button];
        
        UISwitch *switchView = [[UISwitch alloc] init];
        switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:option[@"key"]];
        [switchView addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchView;
    } else {
        if (indexPath.row == 0) {
            // 版本
            cell.textLabel.text = @"小红书+ v0.0.1 @维他入我心";
            cell.userInteractionEnabled = NO;
        } else if (indexPath.row == 1) {
            // GitHub
            cell.textLabel.text = @"GitHub 开源地址";
        } else if (indexPath.row == 2) {
            // Telegram
            cell.textLabel.text = @"Telegram 反馈地址";
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}

- (void)optionTapped:(UIButton *)sender {
    // 拦截了点击事件，什么也不做
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"设置";
    } else if (section == 1) {
        return @"关于";
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_tableView deselectRowAtIndexPath:indexPath animated:YES]; 
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            // GitHub
            [self openGitHub];
        } else if (indexPath.row == 2) {
            // Telegram
            [self openTelegram];
        }
    }
}

- (void)switchValueChanged:(UISwitch *)sender {
    UITableViewCell *cell = (UITableViewCell *)sender.superview;
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell]; 
    NSDictionary *option = options[indexPath.row];
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:option[@"key"]];
}

- (void)openGitHub {
    NSString *githubURLString = @"https://github.com/Wtrwx/XhsPlus";
    NSURL *githubURL = [NSURL URLWithString:githubURLString];
    if ([[UIApplication sharedApplication] canOpenURL:githubURL]) {
        [[UIApplication sharedApplication] openURL:githubURL options:@{} completionHandler:nil];
    }
}

- (void)openTelegram {
    NSString *telegramURLString = @"https://t.me/wtrwx";
    NSURL *telegramURL = [NSURL URLWithString:telegramURLString];
    if ([[UIApplication sharedApplication] canOpenURL:telegramURL]) {
        [[UIApplication sharedApplication] openURL:telegramURL options:@{} completionHandler:nil];
    }
}

- (void)killProcess {
    NSLog(@"[XhsPlus] killProcess");
    exit(0);
}

- (void)dismissSettings {
    [self dismissViewControllerAnimated:YES completion:^{
        instance = nil;
    }];
}

@end

