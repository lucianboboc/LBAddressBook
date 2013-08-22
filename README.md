LBAddressBook
=============

Sample project to export/import vCard using AddressBook framework

How to use LBAddressBook
=============

1. Import <code>AddressBook</code> and <code>AddressBookUI</code> frameworks.
2. Ask for address book permissions by calling <code>requestPermissionsWithCompletionBlock:</code>
3. To create a vCard from your contacts (after you have requested permissions) call the <code>createVCardData</code> method.
4. To remove all contacts and gropus from the address book database call the <code>removeCurrentContactsAndGroups</code> method.
5. To add contacts from a vCard to the address book database call the <code>addContactsFromVCard:</code> method.

EXAMPLE
=============
```
// request permissions
    __block NSData *vCard = nil;
    [LBAddressBook requestPermissionsWithCompletionBlock:^(BOOL granted, NSError *error) {
        if(granted)
        {
            // creat the vCard
            vCard = [LBAddressBook createVCardData];
        }
        else
            NSLog(@"error: %@",error.localizedDescription);
    }];
    
    
    // to remove all the contacts and groups
    [LBAddressBook removeCurrentContactsAndGroups];
    
    // add contacts from vCard data
    [LBAddressBook addContactsFromVCard: vCard];
```    
 
Enjoy!
