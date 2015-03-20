//
//  MatchUpSettingsViewController.m
//  ShareNear
//
//  Created by Ke Luo on 2/6/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "MatchUpSettingsViewController.h"

@interface MatchUpSettingsViewController ()

@property (weak, nonatomic) IBOutlet UISlider *ageSlider;

@property (weak, nonatomic) IBOutlet UISwitch *menSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *womenSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *singleSwitch;

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;

@property (weak, nonatomic) IBOutlet UILabel *ageLabel;

@end

@implementation MatchUpSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Settings";
    
    self.ageSlider.value = [[NSUserDefaults standardUserDefaults] integerForKey:kAgeMaxKey];
    self.menSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kMenEnableKey];
    self.womenSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kWomenEnabledKey];
    self.singleSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kSingleEnabledKey];
    
    [self.ageSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.menSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.womenSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.singleSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.ageLabel.text = [NSString stringWithFormat:@"%i", (int)self.ageSlider.value];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)logoutButtonPressed:(id)sender {
    [PFUser logOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)editProfileButtonPressed:(id)sender {
}

#pragma mark - Helper Methods

-(void)valueChanged:(id)sender{
    if (sender == self.ageSlider){
        [[NSUserDefaults standardUserDefaults] setInteger:self.ageSlider.value forKey:kAgeMaxKey];
        self.ageLabel.text = [NSString stringWithFormat:@"%i", (int)self.ageSlider.value];
    }
    else if (sender == self.menSwitch){
        [[NSUserDefaults standardUserDefaults] setBool:self.menSwitch.isOn forKey:kMenEnableKey];
    }
    else if (sender == self.womenSwitch){
        [[NSUserDefaults standardUserDefaults] setBool:self.womenSwitch.isOn forKey:kWomenEnabledKey];
    }
    else if (sender == self.singleSwitch){
        [[NSUserDefaults standardUserDefaults] setBool:self.singleSwitch.isOn forKey:kSingleEnabledKey];
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
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
