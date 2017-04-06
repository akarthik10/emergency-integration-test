//
//  GGAttributeDetailViewController.m
//  UMassEmergency
//
//  Created by Görkem Güclü on 11.07.16.
//  Copyright © 2016 University of Massachusetts.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you
//  may not use this file except in compliance with the License. You
//  may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
//  implied. See the License for the specific language governing
//  permissions and limitations under the License.
//

#import "GGAttributeDetailViewController.h"
#import "GGApp.h"

@interface GGAttributeDetailViewController () <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) UIPickerView *picker;

@end

@implementation GGAttributeDetailViewController



#pragma mark - table

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.attribute.options.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    GGAttributeValue *option = [self.attribute.options objectAtIndex:indexPath.row];
    cell.textLabel.text = option.title;
    
    if ([self.attribute.selectedValues containsObject:option]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *selectedValues = [[NSMutableArray alloc] initWithArray:self.attribute.selectedValues];
    GGAttributeValue *option = [self.attribute.options objectAtIndex:indexPath.row];
    
    if ([selectedValues containsObject:option]) {
        [selectedValues removeObject:option];
    }else{
        [selectedValues addObject:option];
    }

    self.attribute.selectedValues = selectedValues;
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark -

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.attribute.options.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    GGAttributeValue *option = [self.attribute.options objectAtIndex:row];
    return option.title;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    GGAttributeValue *option = [self.attribute.options objectAtIndex:row];
    self.attribute.selectedValues = [NSArray arrayWithObject:option];
}


#pragma mark -

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[GGApp instance].dataManager uploadAttributesPreferencesWithCompletion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.945 alpha:1.000];
        
    self.picker = [[UIPickerView alloc] initWithFrame:self.view.bounds];
    self.picker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.picker.delegate = self;
    self.picker.dataSource = self;
    [self.view addSubview:self.picker];
    
    if (self.attribute) {
        
        self.title = self.attribute.title;
        
        if (self.attribute.selectCount > 1) {
            // use table
            
            self.table.hidden = NO;
            self.picker.hidden = YES;
            
        }else{
            
            // use picker
            self.table.hidden = YES;
            self.picker.hidden = NO;
            
            if (self.attribute.selectedValues.count == 1) {
                GGAttributeValue *value = self.attribute.selectedValues[0];
                NSUInteger index = [self.attribute.options indexOfObject:value];
                [self.picker selectRow:index inComponent:0 animated:NO];
            }
            
        }
        
    }
}


@end
