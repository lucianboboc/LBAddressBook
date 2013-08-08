//
//  ViewController.m
//  LBAddressBook
//
//  Created by Lucian Boboc on 8/9/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import "ViewController.h"
#import "LBAddressBook.h"

@interface ViewController ()  <ABPeoplePickerNavigationControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    __block NSData *vCard = nil;
    [LBAddressBook requestPermissionsWithCompletionBlock:^(BOOL granted, NSError *error) {
        if(granted)
        {
            vCard = [LBAddressBook createVCardData];
            
            // DO SOMETHING WITH THE VCARD
        }
        else
            NSLog(@"error: %@",error.localizedDescription);
    }];
    
    
    
    // after delay remove current contacts and add them from the vcard created earlier
    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [LBAddressBook removeCurrentContactsAndGroups];
        [LBAddressBook addContactsFromVCard: vCard];
    });

    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}













- (IBAction)showPicker:(id)sender
{
    ABPeoplePickerNavigationController *controller = [[ABPeoplePickerNavigationController alloc] init];
    controller.peoplePickerDelegate = self;
    [self presentViewController: controller animated: YES completion: nil];
}




- (void)peoplePickerNavigationControllerDidCancel: (ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (BOOL)peoplePickerNavigationController: (ABPeoplePickerNavigationController *)peoplePicker       shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    [self dismissViewControllerAnimated: YES completion:nil];
    return YES;
}

- (BOOL)peoplePickerNavigationController: (ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    return YES;
}





@end
