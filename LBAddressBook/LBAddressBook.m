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

+ (NSArray *) getAllContacts
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
        
        CFRelease(addressBook);
        
        return (__bridge_transfer NSArray*)personsArray;
    }
}




+ (NSData *)createVCardDataFromArray: (NSArray *) array
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
        if(!array)
            return nil;
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
        CFArrayRef personsArray = (__bridge CFArrayRef)array;
        
        CFDataRef vCardData = NULL;
        if(personsArray)
            vCardData = ABPersonCreateVCardRepresentationWithPeople(personsArray);
        
        if(addressBook != NULL)
            CFRelease(addressBook);
        
        if(vCardData)
            return (__bridge_transfer NSData *)vCardData;
        return nil;
    }
}




+ (NSArray *) createArrayFromVCardData: (NSData *) vCardData
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
        if(!vCardData)
            return nil;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABRecordRef record = ABAddressBookCopyDefaultSource(addressBook);
        
        if(record)
        {
            CFArrayRef personsArray = ABPersonCreatePeopleInSourceWithVCardRepresentation(record, (__bridge CFDataRef)vCardData);
            
            CFRelease(record);
            CFRelease(addressBook);
            
            if(personsArray)
                return (__bridge_transfer NSArray *)personsArray;
            else
                return nil;
        }
        else
        {
            CFRelease(addressBook);
            return nil;
        }
    }
}




+ (NSUInteger) countContactsInVCardData: (NSData *) vCardData
{
    ABAuthorizationStatus code = ABAddressBookGetAuthorizationStatus();
    if(code != kABAuthorizationStatusAuthorized)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Message" message: [self getStringMessageForStatus:code] delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [alert show];
        return 0;
    }
    else
    {
        if(!vCardData)
            return 0;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABRecordRef record = ABAddressBookCopyDefaultSource(addressBook);
        
        if(record)
        {
            CFArrayRef personsArray = ABPersonCreatePeopleInSourceWithVCardRepresentation(record, (__bridge CFDataRef)vCardData);
            
            CFRelease(record);
            CFRelease(addressBook);
            
            if(personsArray)
            {
                CFIndex count = CFArrayGetCount(personsArray);
                CFRelease(personsArray);
                return count;
            }
            else
                return 0;
        }
        else
        {
            CFRelease(addressBook);
            return 0;
        }
    }
    
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




+ (NSMutableArray *) sortContactsFromArray: (NSArray *) contacts
{
    if(!contacts)
        return nil;
    
    CFMutableArrayRef contactsMutable = CFArrayCreateMutableCopy(
                                                                 kCFAllocatorDefault,
                                                                 contacts.count,
                                                                 (__bridge CFArrayRef)contacts
                                                                 );
    
    if(contactsMutable)
    {
        CFArraySortValues(contactsMutable,
                          CFRangeMake(0, CFArrayGetCount(contactsMutable)),
                          (CFComparatorFunction) ABPersonComparePeopleByName,
                          (void*) ABPersonGetSortOrdering());
    }
    
    return (__bridge_transfer NSMutableArray *)contactsMutable;
}




+ (BOOL) deleteContactWithRecord: (ABRecordRef) record
{
    ABAuthorizationStatus code = ABAddressBookGetAuthorizationStatus();
    if(code != kABAuthorizationStatusAuthorized)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Message" message: [self getStringMessageForStatus:code] delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    else
    {
        if(!record)
            return NO;
        else
        {
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            ABRecordRef refToDelete = ABAddressBookGetPersonWithRecordID(addressBook,ABRecordGetRecordID(record));
            if(refToDelete != NULL)
            {
                bool success = ABAddressBookRemoveRecord(addressBook, refToDelete, NULL);
                ABAddressBookSave(addressBook, NULL);
                CFRelease(addressBook);
                return success;
            }
            else
            {
                CFRelease(addressBook);
                return NO;
            }
        }
    }
}


+ (BOOL) createContactWithRecord: (ABRecordRef) record
{
    ABAuthorizationStatus code = ABAddressBookGetAuthorizationStatus();
    if(code != kABAuthorizationStatusAuthorized)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Message" message: [self getStringMessageForStatus:code] delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    else
    {
        if(!record)
            return NO;
        else
        {
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            bool success = ABAddressBookAddRecord(addressBook, record, NULL);
            ABAddressBookSave(addressBook, NULL);
            CFRelease(addressBook);
            return success;
        }
    }
}


@end
