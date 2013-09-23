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

// get all the contacts.
+ (NSArray *) getAllContacts;

// this method will create a vCard from all contacts and return the NSData vCard.
+ (NSData *)createVCardDataFromArray: (NSArray *) array;

// this method will create a contacts array from a vCard
+ (NSArray *) createArrayFromVCardData: (NSData *) vCard;

// this method will return the contacts count from the vCard
+ (NSUInteger) countContactsInVCardData: (NSData *) vCard;

// this method will create a vCard from all contacts and return the NSData vCard.
+ (NSData *)createVCardData;

// this method will remove all the contacts and groups from the adress book database.
+ (void) removeCurrentContactsAndGroups;

// this method will take a vCard parameter and add all contacts to the address book database.
+ (void) addContactsFromVCard: (NSData *) vCardData;

// this methiod will sort contacts by name
+ (NSMutableArray *) sortContactsFromArray: (NSArray *) contacts;

// this method will delete a contact with ABRecordRef
+ (BOOL) deleteContactWithRecord: (ABRecordRef) record;

// this method will create a contact with ABRecordRef
+ (BOOL) createContactWithRecord: (ABRecordRef) record;
@end
