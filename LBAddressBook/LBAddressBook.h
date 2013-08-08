//
//  LBAddressBook.h
//  AB
//
//  Created by Lucian Boboc on 8/8/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>

typedef void(^AddressBookPermissionsBlock)(BOOL granted, NSError *error);

@interface LBAddressBook : NSObject
// if the granted bool is YES, error is nil, otherwise NSError has the errorCode of the authorization status and the localized description.
+ (void) requestPermissionsWithCompletionBlock: (AddressBookPermissionsBlock) completionBlock;

// this method will create a vCard from all contacts and return the NSData vCard.
+ (NSData *)createVCardData;

// this method will remove all the contacts and groups from the adress book database.
+ (void) removeCurrentContactsAndGroups;

// this method will take a vCard parameter and add all contacts to the address book database.
+ (void) addContactsFromVCard: (NSData *) vCardData;
@end
