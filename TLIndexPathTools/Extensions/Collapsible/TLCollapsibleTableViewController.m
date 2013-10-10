//
//  TLCollapsibleTableViewController.m
//
//  Copyright (c) 2013 Tim Moose (http://tractablelabs.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "TLCollapsibleTableViewController.h"
#import "TLCollapsibleHeaderView.h"
#import "UITableViewController+ScrollOptimizer.h"

@interface TLCollapsibleTableViewController ()

@end

@implementation TLCollapsibleTableViewController

- (void)commonInit {
    _optimizeScrollOnExpand = YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:style]) {
        [self commonInit];
    }
    return self;
}

- (TLCollapsibleDataModel *)dataModel {
    return (TLCollapsibleDataModel *)self.indexPathController.dataModel;
}

- (void)setDataModel:(TLCollapsibleDataModel *)dataModel
{
    self.indexPathController.dataModel = dataModel;
}

- (void)configureHeaderView:(TLCollapsibleHeaderView *)headerView forSection:(NSInteger)section
{
}

#pragma mark - UITableViewDelegate

/**
 Override this to customize header view height
*/
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat width = self.tableView.frame.size.width;
    CGFloat height = [self tableView:self.tableView heightForHeaderInSection:section];
    TLCollapsibleHeaderView *headerView = [[TLCollapsibleHeaderView alloc] initWithFrame:CGRectMake(0, 0, width, height) andSection:section];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSectionTap:)];
    headerView.titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    [headerView addGestureRecognizer:tapRecognizer];
    [self configureHeaderView:headerView forSection:section];
    return headerView;
}

- (void) handleSectionTap:(UITapGestureRecognizer *)sender
{
    TLCollapsibleHeaderView *headerView = (TLCollapsibleHeaderView *)sender.view;
    NSInteger section = headerView.section;
    NSString *sectionName = [self.dataModel sectionNameForSection:section];
    NSMutableSet *collapsedSectionNames = [NSMutableSet setWithSet:self.dataModel.collapsedSectionNames];
    BOOL collapsed = NO;
    if ([collapsedSectionNames containsObject:sectionName]) {
        if (self.singleExpandedSection) {
            [collapsedSectionNames removeAllObjects];
            [collapsedSectionNames addObjectsFromArray:[self.dataModel sectionNames]];
        }
        [collapsedSectionNames removeObject:sectionName];
    } else {
        [collapsedSectionNames addObject:sectionName];
        collapsed = YES;
    }

    self.dataModel = [[TLCollapsibleDataModel alloc] initWithBackingDataModel:self.dataModel.backingDataModel collapsedSectionNames:collapsedSectionNames];

    if ([self.delegate respondsToSelector:@selector(controller:didChangeSection:collapsed:)]) {
        [self.delegate controller:self didChangeSection:section collapsed:collapsed];
    }
    if (!collapsed && self.optimizeScrollOnExpand) {
        [self optimizeScrollPositionForSection:section headerView:headerView dataModel:self.dataModel animated:YES];
    }
    
    [self configureHeaderView:headerView forSection:section];
}

@end
