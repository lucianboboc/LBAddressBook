//
//  LBAddressBook.m
//  AB
//
//  Created by Lucian Boboc on 8/8/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import "LBAddressBook.h"

@implementation LBAddressBook

+ (NSString *) getStringMessageForStatus: (int) status
{
    if(status == 0)
        return @"No authorization status could be determined";
    else if(status == 1)
        return @"The app is not authorized to access address book data. You cannot change this access, possibly due to restrictions such as parental controls.";
    else if(status == 2)
        return @"You have explicitly denied access to address book data for this app, please go to Settings/Privacy and enable Contacts access for this app.";
    else
        return @"The app is authorized to access address book data.";
}

+ (void) requestPermissionsWithCompletionBlock: (AddressBookPermissionsBlock) completionBlock
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    ABAddressBookRequestAccessWithCompletion(addressBook,^(bool granted, CFErrorRef error) {
        dispatch_async(dispatch_get_main_queue(),^{
            if (granted)
            {
                if(completionBlock)
                    completionBlock(YES,nil);
            }
            else
            {
                if(completionBlock)
                {
                    NSError *err = nil;
                    if(error)
                    {
                        err = (__bridge_transfer NSError *)CFErrorCopyDescription(error);
                        completionBlock(NO,err);
                    }
                    else
                    {
                        ABAuthorizationStatus code = ABAddressBookGetAuthorizationStatus();
                        NSString *stringError = [self getStringMessageForStatus: code];
                        err = [NSError errorWithDomain: @"LBAddressBook" code: code userInfo: @{NSLocalizedDescriptionKey: stringError}];
                        completionBlock(NO,err);
                    }
                        
                }
            }
        });
    });

    if(addressBook)
        CFRelease(addressBook);
}


+ (NSData *)createVCardData
{
    ABAuthorizationStatus code = ABAddressBookGetAuthorizationStatus();
    if(code != kABAuthorizationStatusAuthorized)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Message" message: [self getStringMessageForStatus:code] delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [alert show];
        return nil;
    }
    else
    {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
        CFArrayRef personsArray = ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        CFDataRef vCardData = NULL;
        if(personsArray)
        {
            vCardData = ABPersonCreateVCardRepresentationWithPeople(personsArray);
            CFRelease(personsArray);
        }
        
        CFRelease(addressBook);
        
        if(vCardData)
            return (__bridge_transfer NSData *)vCardData;
        return nil;
    }
}



+ (void) removeCurrentContactsAndGroups
{
    ABAuthorizationStatus code = ABAddressBookGetAuthorizationStatus();
    if(code != kABAuthorizationStatusAuthorized)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Message" message: [self getStringMessageForStatus:code] delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
        CFArrayRef personsArray = ABAddressBookCopyArrayOfAllPeople(addressBook);
        if(personsArray)
        {
            for(int i = 0; i < CFArrayGetCount(personsArray); i++)
            {
                ABRecordRef record = CFArrayGetValueAtIndex(personsArray, i);
                ABAddressBookRemoveRecord(addressBook, record, NULL);
            }
            CFRelease(personsArray);
        }
        
        
        CFArrayRef groupsArray = ABAddressBookCopyArrayOfAllGroups(addressBook);
        if(groupsArray)
        {
            for(int i = 0; i < CFArrayGetCount(groupsArray); i++)
            {
                ABRecordRef record = CFArrayGetValueAtIndex(groupsArray, i);
                ABAddressBookRemoveRecord(addressBook, record, NULL);
            }
            CFRelease(groupsArray);
        }
        
        if(addressBook)
        {
            ABAddressBookSave(addressBook, NULL);     
            CFRelease(addressBook);
        }
    }
}




+ (void) addContactsFromVCard: (NSData *) vCardData
{
    ABAuthorizationStatus code = ABAddressBookGetAuthorizationStatus();
    if(code != kABAuthorizationStatusAuthorized)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Message" message: [self getStringMessageForStatus:code] delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        if(vCardData)
        {
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            ABRecordRef record = ABAddressBookCopyDefaultSource(addressBook);
            
            if(record)
            {
                CFArrayRef personsArray = ABPersonCreatePeopleInSourceWithVCardRepresentation(record, (__bridge CFDataRef)vCardData);
                if(personsArray)
                {
                    for(int i = 0; i < CFArrayGetCount(personsArray); i++)
                    {
                        ABRecordRef rec = CFArrayGetValueAtIndex(personsArray, i);
                        ABAddressBookAddRecord(addressBook, rec, NULL);
                    }
                    CFRelease(personsArray);
                }
                CFRelease(record);                
            }
            
            if(addressBook)
            {
                ABAddressBookSave(addressBook, NULL);
                CFRelease(addressBook);
            }
        }
    }
}


@end
