//
//  HelpDietViewController.m
//  HealthApp
//
//  Created by David Neubauer on 4/5/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "HelpDietViewController.h"
#import "DietHelpView.h"

#define HEX_SEPARATION 5
#define PROTEIN 0
#define FRUIT 320
#define GRAINS 640
#define DAIRY 960
#define VEGGIE 1280
#define JUNK 1600


@interface HelpDietViewController ()
{
    UIColor *eggWhite;
    UIColor *darkerGray;
    UIColor *lighterGray;
    UIColor *mint;
    
    UIColor *fruitColor;
    UIColor *grainColor;
    UIColor *proteinColor;
    UIColor *veggieColor;
    UIColor *dairyColor;
    
    CGPoint touchLocation;
    
    UIImageView *fruitImage;
    UIImageView *grainImage;
    UIImageView *dairyImage;
    UIImageView *veggieImage;
    UIImageView *junkImage;
    UIImageView *proteinImage;
    
    int foodGroups;
    int currentFoodGroup;
    
    UIScrollView *mainScrollView;
    
    UIScrollView *foodGroupsScroll;
    UIPageControl *pageControl;
    
    NSArray *fruitInfo;
    NSArray *grainsInfo;
    NSArray *dairyInfo;
    NSArray *veggieInfo;
    NSArray *junkInfo;
    NSArray *proteinInfo;
    
    UILabel *fruitLabel;
    UILabel *grainsLabel;
    UILabel *dairyLabel;
    UILabel *veggieLabel;
    UILabel *junkLabel;
    UILabel *proteinLabel;
}
@end

@implementation HelpDietViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        eggWhite = [UIColor colorWithRed:(218/255.0) green:(218/255.0) blue:(218/255.0) alpha:1.0];
        darkerGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:1.0];
        lighterGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.7];
        mint = [UIColor colorWithRed:(63/255.0) green:(195/255.0) blue:(128/255.0) alpha:1.0];
        
        fruitColor = [UIColor colorWithRed:(224/255.0) green:(130/255.0) blue:(131/255.0) alpha:1.0];
        grainColor = [UIColor colorWithRed:(254/255.0) green:(201/255.0) blue:(86/255.0) alpha:1.0];
        proteinColor = [UIColor colorWithRed:(179/255.0) green:(136/255.0) blue:(221/255.0) alpha:1.0];
        veggieColor = [UIColor colorWithRed:(163/255.0) green:(215/255.0) blue:(112/255.0) alpha:1.0];
        dairyColor = [UIColor colorWithRed:(137/255.0) green:(196/255.0) blue:(244/255.0) alpha:1.0];
        
        touchLocation = CGPointMake(0, 0);
        
        foodGroups = 0x0;
        
        
        proteinInfo = [[NSArray alloc] initWithObjects:@"6.5 Ounces", @"1 Ounce Meat", @"1 Ounce", @"1 Egg", @"1 Ounce", @"1 Tablespoon Peanut Butter", @"1 Ounce", nil];
        fruitInfo = [[NSArray alloc] initWithObjects:@"2 Cups", @"Apple", @"1 Cup", @"Banana", @"1 Cup", @"8 Strawberries", @"1 Cup", nil];
        grainsInfo = [[NSArray alloc] initWithObjects:@"8 Ounces", @"Bagel", @"4 Ounces", @"Slice of Bread", @"1 Ounce", @"1 Large Tortilla", @"4 Ounces", nil];
        dairyInfo = [[NSArray alloc] initWithObjects:@"3 Cups", @"Milk", @"1 Cup", @"Yogurt", @"1 Cup", @"1 Slice Hard Cheese", @"0.5 Cup", nil];
        veggieInfo = [[NSArray alloc] initWithObjects:@"3 Cups", @"2 Cups Raw Leafy Greens", @"1 Cup", @"12 Baby Carrots", @"1 Cup", @"1 Medium White Potato", @"1 Cup", nil];
        junkInfo = [[NSArray alloc] initWithObjects:@"", @"Candy", @"", @"Soda", @"", @"Sweet Desserts", @"", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    // Main View
    CGRect frame = [[UIScreen mainScreen] bounds];
    DietHelpView *view = [[DietHelpView alloc] initWithFrame:frame];
    [self setView:view];
    
    // Back Button
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(6, 20, 44, 44)];
    [backButton setImage:[UIImage imageNamed:@"arrow_backward"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(closeHelp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    // Title
    CGRect titleFrame = CGRectMake(0, 20, self.view.frame.size.width, 44);
    UILabel *title = [[UILabel alloc] initWithFrame:titleFrame];
    [title setText:@"Food Help"];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:32.0]];
    [title setTextColor:darkerGray];
    [self.view addSubview:title];
    
    // Scroll View
    CGRect scrollFrame = frame;
    scrollFrame.origin.y += 64;
    scrollFrame.size.height -= 64;
    mainScrollView = [[UIScrollView alloc] init];
    mainScrollView.frame = scrollFrame;
    mainScrollView.contentSize = CGSizeMake(320, 504);
    mainScrollView.scrollEnabled = ((int)frame.size.height != 568);
    mainScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:mainScrollView];
    [self.view sendSubviewToBack:mainScrollView];
    
    // Touch Delegate
    UIView *gestureView = [[UIView alloc] init];
    gestureView.frame = CGRectMake((frame.size.width-214)/2.0, 18, 214, 244);
    [mainScrollView addSubview:gestureView];
    
    UITapGestureRecognizer *tap_gr = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(userTouchDetected:)];
    [gestureView setGestureRecognizers:[NSArray arrayWithObjects:tap_gr, nil]];
    
    // Food Group Hex
    [self setUpFoodHex];
    currentFoodGroup = 0;
    [self showFoodGroup:-1];
    
    // Title Bar Backgrounds
    UIView *titleBarLeftBackground = [[UIView alloc] initWithFrame:CGRectMake(0, mainScrollView.contentSize.height - 196, 160, 44)];
    [titleBarLeftBackground setBackgroundColor:proteinColor];
    [mainScrollView addSubview:titleBarLeftBackground];
    
    UIView *titleBarRightBackground = [[UIView alloc] initWithFrame:CGRectMake(160, mainScrollView.contentSize.height - 196, 160, 44)];
    [titleBarRightBackground setBackgroundColor:darkerGray];
    [mainScrollView addSubview:titleBarRightBackground];

    CGRect scrollViewRect = CGRectMake(0, mainScrollView.contentSize.height - 196,
                                        self.view.frame.size.width, 176);
    foodGroupsScroll = [[UIScrollView alloc]
                                initWithFrame:scrollViewRect];
    [foodGroupsScroll setBackgroundColor:[UIColor clearColor]];
    [foodGroupsScroll setUserInteractionEnabled:YES];
    [foodGroupsScroll setDelegate:self];
    [foodGroupsScroll setPagingEnabled:YES];
    [foodGroupsScroll setShowsHorizontalScrollIndicator:NO];
    [foodGroupsScroll setContentSize:CGSizeMake(self.view.frame.size.width * 6.0, 176)];
    [mainScrollView addSubview:foodGroupsScroll];
    
    // Tables
    for (int i = 0; i < 6; i++) {
        CGRect tableFrame = CGRectMake(self.view.frame.size.width * i, 0,
                                       self.view.frame.size.width, 176);
        UITableView *table = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
        [table setBackgroundColor:eggWhite];
        [table setSeparatorColor:lighterGray];
        [table setUserInteractionEnabled:NO];
        [table setDelegate:self];
        [table setDataSource:self];
        [table setTag:i];
        [foodGroupsScroll addSubview:table];
    }
    
    // Page Control
    CGRect pageControlView = CGRectMake(0, mainScrollView.contentSize.height - 20,
                                        self.view.frame.size.width, 20);
    pageControl = [[UIPageControl alloc] initWithFrame:pageControlView];
    [pageControl setNumberOfPages:6];
    [pageControl setPageIndicatorTintColor:lighterGray];
    [pageControl setCurrentPageIndicatorTintColor:darkerGray];
    [mainScrollView addSubview:pageControl];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = [scrollView contentOffset];
    int foodGroup = offset.x / self.view.frame.size.width;
    [self showFoodGroup:foodGroup];
}

- (void)setUpFoodHex
{
    // Protein
    proteinImage = [[UIImageView alloc] initWithFrame:CGRectMake(68, 86, 92, 107)];
    [proteinImage setImage:[UIImage imageNamed:@"hex_6"]];
    [mainScrollView addSubview:proteinImage];
    
    proteinLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 129, 64, 20)];
    [proteinLabel setTextColor:darkerGray];
    [proteinLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0]];
    [proteinLabel setTextAlignment:NSTextAlignmentCenter];
    [proteinLabel setText:@"Protein"];
    [mainScrollView addSubview:proteinLabel];
    
    // Fruit
    fruitImage = [[UIImageView alloc] initWithFrame:CGRectMake(68, 33, 92, 107)];
    [fruitImage setImage:[UIImage imageNamed:@"hex_1"]];
    [mainScrollView addSubview:fruitImage];
    
    fruitLabel = [[UILabel alloc] initWithFrame:CGRectMake(54, 37, 106, 20)];
    [fruitLabel setTextColor:darkerGray];
    [fruitLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0]];
    [fruitLabel setTextAlignment:NSTextAlignmentCenter];
    [fruitLabel setTransform:CGAffineTransformMakeRotation(11*M_PI / 6.0)];
    [fruitLabel setText:@"Fruit"];
    [mainScrollView addSubview:fruitLabel];
    
    // Grains
    grainImage = [[UIImageView alloc] initWithFrame:CGRectMake(160, 33, 92, 107)];
    [grainImage setImage:[UIImage imageNamed:@"hex_2"]];
    [mainScrollView addSubview:grainImage];
    
    grainsLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 37, 106, 20)];
    [grainsLabel setTextColor:darkerGray];
    [grainsLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0]];
    [grainsLabel setTextAlignment:NSTextAlignmentCenter];
    [grainsLabel setTransform:CGAffineTransformMakeRotation(M_PI / 6.0)];
    [grainsLabel setText:@"Grains"];
    [mainScrollView addSubview:grainsLabel];
    
    // Dairy
    dairyImage = [[UIImageView alloc] initWithFrame:CGRectMake(160, 86, 92, 107)];
    [dairyImage setImage:[UIImage imageNamed:@"hex_3"]];
    [mainScrollView addSubview:dairyImage];
    
    dairyLabel = [[UILabel alloc] initWithFrame:CGRectMake(246, 129, 64, 20)];
    [dairyLabel setTextColor:darkerGray];
    [dairyLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0]];
    [dairyLabel setTextAlignment:NSTextAlignmentCenter];
    [dairyLabel setText:@"Dairy"];
    [mainScrollView addSubview:dairyLabel];
    
    // Veggie
    veggieImage = [[UIImageView alloc] initWithFrame:CGRectMake(160, 140, 92, 107)];
    [veggieImage setImage:[UIImage imageNamed:@"hex_4"]];
    [mainScrollView addSubview:veggieImage];
    
    veggieLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 222, 106, 20)];
    [veggieLabel setTextColor:darkerGray];
    [veggieLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0]];
    [veggieLabel setTextAlignment:NSTextAlignmentCenter];
    [veggieLabel setTransform:CGAffineTransformMakeRotation(11*M_PI / 6.0)];
    [veggieLabel setText:@"Veggie"];
    [mainScrollView addSubview:veggieLabel];
    
    // Junk
    junkImage = [[UIImageView alloc] initWithFrame:CGRectMake(68, 139, 92, 107)];
    [junkImage setImage:[UIImage imageNamed:@"hex_5"]];
    [mainScrollView addSubview:junkImage];
    
    junkLabel = [[UILabel alloc] initWithFrame:CGRectMake(54, 222, 106, 20)];
    [junkLabel setTextColor:darkerGray];
    [junkLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0]];
    [junkLabel setTextAlignment:NSTextAlignmentCenter];
    [junkLabel setTransform:CGAffineTransformMakeRotation(M_PI / 6.0)];
    [junkLabel setText:@"Junk"];
    [mainScrollView addSubview:junkLabel];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    touchLocation = [touch locationInView:self.view];
    
    if (touchLocation.x >= 44 && touchLocation.x <= 276) {
        if (touchLocation.y >= 87 && touchLocation.y <= 320) {
            [self addFoodGroup:touchLocation];
        }
    }
}

- (void)userTouchDetected:(UITapGestureRecognizer *)tap_gr
{
    touchLocation = [tap_gr locationInView:mainScrollView];
    
    if (touchLocation.x >= 44 && touchLocation.x <= 276) {
        if (touchLocation.y >= 87 && touchLocation.y <= 320) {
            [self addFoodGroup:touchLocation];
        }
    }
}

- (void)addFoodGroup:(CGPoint)touch
{
    CGPoint p1 = CGPointMake(68 , 86);
    CGPoint p2 = CGPointMake(160, 33);
    CGPoint p3 = CGPointMake(252, 86);
    CGPoint p4 = CGPointMake(252, 193);
    CGPoint p5 = CGPointMake(160, 246);
    CGPoint p6 = CGPointMake(68 , 193);
    
    BOOL leftOfVertical = [self point:touch onLeftSideOfLineFromPoint:p2 toPoint:p5];
    BOOL aboveNegSlope2 = [self point:touch onLeftSideOfLineFromPoint:p4 toPoint:p1];
    BOOL abovePosSlope2 = [self point:touch onLeftSideOfLineFromPoint:p3 toPoint:p6];
    
    BOOL fruit   =  leftOfVertical &&  aboveNegSlope2;
    BOOL grains  = !leftOfVertical &&  abovePosSlope2;
    BOOL dairy   =  aboveNegSlope2 &&  !abovePosSlope2;
    BOOL veggie  = !leftOfVertical && !aboveNegSlope2;
    BOOL junk    =  leftOfVertical && !abovePosSlope2;
    BOOL protein = !aboveNegSlope2 &&  abovePosSlope2;
    
    
    if (protein) {
        [self showFoodGroup:0];
    }
    else if (fruit) {
        [self showFoodGroup:1];
    }
    else if (grains) {
        [self showFoodGroup:2];
    }
    else if (dairy) {
        [self showFoodGroup:3];
    }
    else if (veggie) {
        [self showFoodGroup:4];
    }
    else if (junk) {
        [self showFoodGroup:5];
    }
}

- (BOOL)point:(CGPoint)touch onLeftSideOfLineFromPoint:(CGPoint)p1 toPoint:(CGPoint)p2
{
    return ((p2.x - p1.x)*(touch.y - p1.y) - (p2.y - p1.y)*(touch.x - p1.x)) > 0;
}

#pragma mark -
#pragma mark UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 44)];
    [headerLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:24.0]];
    [headerLabel setTextAlignment:NSTextAlignmentLeft];
    [headerLabel setTextColor:darkerGray];
    [view addSubview:headerLabel];
    
    UILabel *targetLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 0, 150, 44)];
    [targetLabel setTextAlignment:NSTextAlignmentRight];
    [targetLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0]];
    [targetLabel setTextColor:darkerGray];
    [view addSubview:targetLabel];
    
//    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 2)];
//    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 2)];
//    [view addSubview:topBar];
//    [view addSubview:bottomBar];
    
    int tableOriginX = (int)tableView.frame.origin.x;
    switch (tableOriginX) {
        case PROTEIN:
            [headerLabel setText:@"Protein"];
            [targetLabel setText:[NSString stringWithFormat:@"Target: %@", [proteinInfo objectAtIndex:0]]];
            [view setBackgroundColor:proteinColor];
            break;
        case FRUIT:
            [headerLabel setText:@"Fruit"];
            [targetLabel setText:[NSString stringWithFormat:@"Target: %@", [fruitInfo objectAtIndex:0]]];
            [view setBackgroundColor:fruitColor];
            [headerLabel setTextColor:eggWhite];
            [targetLabel setTextColor:eggWhite];
            break;
        case GRAINS:
            [headerLabel setText:@"Grains"];
            [targetLabel setText:[NSString stringWithFormat:@"Target: %@", [grainsInfo objectAtIndex:0]]];
            [view setBackgroundColor:grainColor];
            break;
        case DAIRY:
            [headerLabel setText:@"Dairy"];
            [targetLabel setText:[NSString stringWithFormat:@"Target: %@", [dairyInfo objectAtIndex:0]]];
            [view setBackgroundColor:dairyColor];
            break;
        case VEGGIE:
            [headerLabel setText:@"Veggie"];
            [targetLabel setText:[NSString stringWithFormat:@"Target: %@", [veggieInfo objectAtIndex:0]]];
            [view setBackgroundColor:veggieColor];
            break;
        case JUNK:
            [headerLabel setText:@"Junk"];
            [targetLabel setText:@""];
            [view setBackgroundColor:darkerGray];
            [headerLabel setTextColor:eggWhite];
            [targetLabel setTextColor:eggWhite];
            break;
        default:
            break;
    }
    
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.textLabel setTextColor:darkerGray];
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0]];
    [cell.detailTextLabel setTextColor:darkerGray];
    [cell.detailTextLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0]];
    [cell setBackgroundColor:eggWhite];
    int textIndex = (int)indexPath.row * 2 + 1;
    int detailIndex = (int)(indexPath.row + 1) * 2;
    switch (tableView.tag) {
        case 0:
            [cell.textLabel setText:[proteinInfo objectAtIndex:textIndex]];
            [cell.detailTextLabel setText:[proteinInfo objectAtIndex:detailIndex]];
            break;
        case 1:
            [cell.textLabel setText:[fruitInfo objectAtIndex:textIndex]];
            [cell.detailTextLabel setText:[fruitInfo objectAtIndex:detailIndex]];
            break;
        case 2:
            [cell.textLabel setText:[grainsInfo objectAtIndex:textIndex]];
            [cell.detailTextLabel setText:[grainsInfo objectAtIndex:detailIndex]];
            break;
        case 3:
            [cell.textLabel setText:[dairyInfo objectAtIndex:textIndex]];
            [cell.detailTextLabel setText:[dairyInfo objectAtIndex:detailIndex]];
            break;
        case 4:
            [cell.textLabel setText:[veggieInfo objectAtIndex:textIndex]];
            [cell.detailTextLabel setText:[veggieInfo objectAtIndex:detailIndex]];
            break;
        case 5:
            [cell.textLabel setText:[junkInfo objectAtIndex:textIndex]];
            [cell.detailTextLabel setText:[junkInfo objectAtIndex:detailIndex]];
            break;
        default:
            [cell.textLabel setText:[NSString stringWithFormat:@"%ld", (long)tableView.tag]];
    }
    
    return cell;
}

- (void)closeHelp:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showFoodGroup:(int)foodGroup
{
    // -1 inidicates initilization of view
    if (foodGroup != -1) {
        [self hideFoodGroup:currentFoodGroup];
        currentFoodGroup = foodGroup;
    }
    else {
        foodGroup = 0;
    }
    
    [foodGroupsScroll setContentOffset:CGPointMake(self.view.frame.size.width * foodGroup, 0) animated:YES];
    
    
    if (foodGroup == 0) {
        CGRect frame = proteinImage.frame;
        [proteinImage setFrame:CGRectMake(frame.origin.x - 2*HEX_SEPARATION, frame.origin.y,
                                          frame.size.width, frame.size.height)];
        CGPoint center = proteinLabel.center;
        [proteinLabel setCenter:CGPointMake(center.x - 2*HEX_SEPARATION, center.y)];
    }
    else if (foodGroup == 1) {
        CGRect frame = fruitImage.frame;
        [fruitImage setFrame:CGRectMake(frame.origin.x - HEX_SEPARATION, frame.origin.y - 2*HEX_SEPARATION,
                                        frame.size.width, frame.size.height)];
        CGPoint center = fruitLabel.center;
        [fruitLabel setCenter:CGPointMake(center.x - HEX_SEPARATION, center.y - 2*HEX_SEPARATION)];
    }
    else if (foodGroup == 2) {
        CGRect frame = grainImage.frame;
        [grainImage setFrame:CGRectMake(frame.origin.x + HEX_SEPARATION, frame.origin.y - 2*HEX_SEPARATION,
                                        frame.size.width, frame.size.height)];
        CGPoint center = grainsLabel.center;
        [grainsLabel setCenter:CGPointMake(center.x + HEX_SEPARATION, center.y - 2*HEX_SEPARATION)];
    }
    else if (foodGroup == 3) {
        CGRect frame = dairyImage.frame;
            [dairyImage setFrame:CGRectMake(frame.origin.x + 2*HEX_SEPARATION, frame.origin.y,
                                            frame.size.width, frame.size.height)];
        CGPoint center = dairyLabel.center;
        [dairyLabel setCenter:CGPointMake(center.x + 2*HEX_SEPARATION, center.y)];
    }
    else if (foodGroup == 4) {
        CGRect frame = veggieImage.frame;
        [veggieImage setFrame:CGRectMake(frame.origin.x + HEX_SEPARATION, frame.origin.y + 2*HEX_SEPARATION,
                                         frame.size.width, frame.size.height)];
        CGPoint center = veggieLabel.center;
        [veggieLabel setCenter:CGPointMake(center.x + 2*HEX_SEPARATION, center.y + 2*HEX_SEPARATION)];
    }
    else if (foodGroup == 5) {
        CGRect frame = junkImage.frame;
            [junkImage setFrame:CGRectMake(frame.origin.x - HEX_SEPARATION, frame.origin.y + 2*HEX_SEPARATION,
                                           frame.size.width, frame.size.height)];
        CGPoint center = junkLabel.center;
        [junkLabel setCenter:CGPointMake(center.x - 2*HEX_SEPARATION, center.y + 2*HEX_SEPARATION)];
    }
    
    [pageControl setCurrentPage:foodGroup];
}

- (void)hideFoodGroup:(int)foodGroup
{
    if (foodGroup == 0) {
        CGRect frame = proteinImage.frame;
        [proteinImage setFrame:CGRectMake(frame.origin.x + 2*HEX_SEPARATION, frame.origin.y,
                                          frame.size.width, frame.size.height)];
        CGPoint center = proteinLabel.center;
        [proteinLabel setCenter:CGPointMake(center.x + 2*HEX_SEPARATION, center.y)];
    }
    else if (foodGroup == 1) {
        CGRect frame = fruitImage.frame;
        [fruitImage setFrame:CGRectMake(frame.origin.x + HEX_SEPARATION, frame.origin.y + 2*HEX_SEPARATION,
                                        frame.size.width, frame.size.height)];
        CGPoint center = fruitLabel.center;
        [fruitLabel setCenter:CGPointMake(center.x + HEX_SEPARATION, center.y + 2*HEX_SEPARATION)];
    }
    else if (foodGroup == 2) {
        CGRect frame = grainImage.frame;
        [grainImage setFrame:CGRectMake(frame.origin.x - HEX_SEPARATION, frame.origin.y + 2*HEX_SEPARATION,
                                        frame.size.width, frame.size.height)];
        CGPoint center = grainsLabel.center;
        [grainsLabel setCenter:CGPointMake(center.x - HEX_SEPARATION, center.y + 2*HEX_SEPARATION)];
    }
    else if (foodGroup == 3) {
        CGRect frame = dairyImage.frame;
        [dairyImage setFrame:CGRectMake(frame.origin.x - 2*HEX_SEPARATION, frame.origin.y,
                                        frame.size.width, frame.size.height)];
        CGPoint center = dairyLabel.center;
        [dairyLabel setCenter:CGPointMake(center.x - 2*HEX_SEPARATION, center.y)];
    }
    else if (foodGroup == 4) {
        CGRect frame = veggieImage.frame;
        [veggieImage setFrame:CGRectMake(frame.origin.x - HEX_SEPARATION, frame.origin.y - 2*HEX_SEPARATION,
                                         frame.size.width, frame.size.height)];
        CGPoint center = veggieLabel.center;
        [veggieLabel setCenter:CGPointMake(center.x - 2*HEX_SEPARATION, center.y - 2*HEX_SEPARATION)];
    }
    else if (foodGroup == 5) {
        CGRect frame = junkImage.frame;
        [junkImage setFrame:CGRectMake(frame.origin.x + HEX_SEPARATION, frame.origin.y - 2*HEX_SEPARATION,
                                       frame.size.width, frame.size.height)];
        CGPoint center = junkLabel.center;
        [junkLabel setCenter:CGPointMake(center.x + 2*HEX_SEPARATION, center.y - 2*HEX_SEPARATION)];
    }
}


@end
