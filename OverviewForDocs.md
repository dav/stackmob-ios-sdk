# Welcome to the docs for the StackMob iOS SDK!

### Current Version: 1.0.0beta.3

### Jump To:
<a href="#overview">Overview</a>

<a href="#getting_started">Getting Started</a>

<a href="#coding_practices">StackMob <--> Core Data Coding Practices</a>

[StackMob <--> Core Data Support Specifications](http://stackmob.github.com/stackmob-ios-sdk/CoreDataSupportSpecs.html)

<a href="#classes_to_check_out">Classes To Check Out</a>

<a href="#tutorials">Tutorials</a>

<a href="#core_data_references">Core Data References</a>

<a href="#class_index">Index of Classes</a>

<a name="overview">&nbsp;</a>
## Overview

The goal of the iOS SDK is to provide the best experience possible for developing an application that uses StackMob as a cloud backend.  

### How is the new iOS SDK different from the older version? 

The biggest difference between the new and the current SDKs is our use of Core Data as a foundation for the new SDK. We believe Core Data is a better approach for integrating StackMob’s REST based API into an iOS application.

We've also separated our Push Notification API into a separate SDK. For more information, see the [iOS Push SDK Reference](http://stackmob.github.com/stackmob-ios-push-sdk/index.html).

### Why base the new SDK on Core Data? 
Our number one goal is to create a better experience. Core Data allows us to place a familiar wrapper around StackMob REST calls and datastore API. iOS developers can leverage their existing knowledge of Core Data to quickly integrate StackMob into their applications.  For those interested in sticking to the REST-based way of making requests, we provide the full data store API.

### Already know Core Data?
Then you already know how to use StackMob!

All you need to do to get started with StackMob is initialize an instance of SMClient and use a configured managed object context by following the instructions in <a href="#getting_started">Initialize an SMClient</a>.

### What's supported with our Core Data integration?

Check out the [StackMob <--> Core Data Support Specifications](http://stackmob.github.com/stackmob-ios-sdk/CoreDataSupportSpecs.html).

### Reporting issues or feature requests  

You can file issues through the [GitHub issue tracker](https://github.com/stackmob/stackmob-ios-sdk/issues).


### Still have questions about the new iOS SDK? 

Email us at [support@stackmob.com](mailto:support@stackmob.com).

<a name="getting_started">&nbsp;</a>
## Getting Started

If you don't already have the StackMob SDK imported into your application, [get started with StackMob](https://stackmob.com/platform/start).

**The fundamental class for StackMob is SMClient**.  From an instance of this class you have access to a configured managed object context and persistent store coordinator as well as a REST-based data store. Check out the [class reference for SMClient](http://stackmob.github.com/stackmob-ios-sdk/Classes/SMClient.html) for more information.  Let's see how to initialize our `SMClient`:

<br/>

### Initialize an SMClient

Wherever you plan to use StackMob, add `#import "StackMob.h"` to the header file.

Create a variable of class `SMClient`, most likely in your AppDelegate file where you initialize other application wide variables, and initialize it like this:

	// Assuming your variable is declared SMClient *client;
	client = [[SMClient alloc] initWithAPIVersion:@"API-VERSION" publicKey:@"PUBLIC-KEY"];

For API-VERSION, pass @"0" for Development, @"1" or higher for the corresponding version in Production.

If you haven't found your public key yet, check out **Manage App Info** under the **App Settings** sidebar on the [Platform page](https://stackmob.com/platform).

<br/>
	
### Start persisting data

There are two ways to persist data to StackMob:

* Core Data
* Lower Level Datastore API

<br/>

#### Core Data


StackMob recommends using Core Data… it provides a powerful and robust object graph management system that otherwise would be a nightmare to implement.  Although it may have a reputation for being pretty complex, the basics are easy to grasp and understand.  If you want to learn the basics, check out <a href="#core_data_references">Core Data References</a> below.

The three main pieces of Core Data are instances of:

* [NSManagedObjectContext](https://developer.apple.com/library/ios/#documentation/Cocoa/Reference/CoreDataFramework/Classes/NSManagedObjectContext\_Class/NSManagedObjectContext.html) - This is what you use to create, read, update and delete objects in your database.
* [NSPersistentStoreCoordinator](https://developer.apple.com/library/ios/#documentation/Cocoa/Reference/CoreDataFramework/Classes/NSPersistentStoreCoordinator\_Class/NSPersistentStoreCoordinator.html) - Coordinates between the managed object context and the actual database, in this case StackMob.
* [NSManagedObjectModel](https://developer.apple.com/library/ios/#documentation/Cocoa/Reference/CoreDataFramework/Classes/NSManagedObjectModel\_Class/Reference/Reference.html) - References a file where you defined your object graph.

**Access a StackMob-configured managed object context**

You can obtain a managed object context configured from your SMClient instance like this:

	// aManagedObjectModel is an initialized instance of NSManagedObjectModel
	// client is your instance of SMClient
	SMCoreDataStore *coreDataStore = [client coreDataStoreWithManagedObjectModel:aManagedObjectModel];
	
	// assuming you have a variable called managedObjectContext
	self.managedObjectContext = [coreDataStore managedObjectContext];
	
Use this instance of NSManagedObjectContext throughout your application. Other than that, use Core Data like you normally would!

**Important:** Make sure you adhere to the <a href="#coding_practices">StackMob <--> Core Data Coding Practices</a>!

<br/>

#### Lower Level Datastore API

If you want to make direct REST-based calls to the datastore, grab an instance of SMDataStore like this:

	SMDataStore *dataStore = [client dataStore];
	
Check out [SMDataStore](http://stackmob.github.com/stackmob-ios-sdk/Classes/SMDataStore.html) for all available methods.

<br/>

### User Authentication

SMClient provides all the necessary methods for user authentication.

The default schema to use for authentication is **user**, with **username** and **password** fields. 

If you plan on using a different user object schema or different field names, check out the **User Authentication** section of the [SMClient Class Reference](http://stackmob.github.com/stackmob-ios-sdk/Classes/SMClient.html).

<a name="coding_practices">&nbsp;</a>
## StackMob <--> Core Data Coding Practices

There are a few coding practices to adhere to as well as general things to know when using StackMob with Core Data.  This allows StackMob to seamlessly translate to and from the language that Core Data speaks.

First, a table of how Core Data, StackMob and regular databases map to each other:
<table cellpadding="8px" width="600px">
	<tr align="center">
		<th>Core Data</th>
		<th>StackMob</th>
		<th>Database</th>
	</tr>
	<tr>
		<td>Entity</td>
		<td>Schema</td>
		<td>Table</td>
	</tr>
	<tr>
		<td>Attribute</td>
		<td>Field</td>
		<td>Column</td>
	</tr>
	<tr>
		<td>Relationship</td>
		<td>Relationship</td>
		<td>Reference Column</td>
	</tr>
</table>

**Coding Practices for successful app development:**

1. **Lowercase Entities:** Core Data entities are encouraged to start with a capital letter and will translate to all lowercase on StackMob. Example: **Superpower** entity on Core Data translates to **superpower** schema on StackMob.
2. **Lowercase Properties:** Core Data attribute and relationship names must be all lowercase and can include underscores (for now). RIGHT: **year_born**, WRONG: **yearBorn**.
3. **Schema Primary Keys:** All StackMob schemas have a primary key field that is always schemaName_id, unless the schema is a user object, in which case it defaults to username but can be changed manually.
4. **Entity Primary Keys:** Following #3, each Core Data entity must include an attribute of type string that maps to the primary key field on StackMob. If it is not schemaName_id, you must adopt the [SMModel](http://stackmob.github.com/stackmob-ios-sdk/Protocols/SMModel.html) protocol. In order to adopt the protocol you will make an NSManagedObject subclass of the entity. This is good to do in general as it automatically provides getters and setters. Example, entity **Soda** should have attribute **soda_id**.
5. **Assign IDs:** When inserting new objects into your managed object context, you must assign an id value to the attribute which maps to the StackMob primary key field BEFORE you make save the context. 
90% of the time you can get away with assigning ids like this:
		
		// assuming your instance is called newManagedObject
		[newManagedObject setValue:[newManagedObject sm_assignObjectId] forKey:[newManagedObject sm_primaryKeyField]];
		
		// now you can make a call to save: on your managed object context
		
	The other 10% of the time is when you want to assign your own ids that aren't unique strings based on a UUID algorithm. A great example of this is user objects, where you would probably assign the user's name to the primary key field. 
		
6. **NSManagedObject Subclasses:** Creating an NSManagedObject subclass for each of your entities is highly recommended for convenience. You can add an init method to each subclass and include the ID assignment line from above - then you don't have to remember to do it each time you create a new object!
7. **Asynchronous Save Calls:** Core Data performs synchronous calls to its Persistent Store. To get the effect of asynchronous save: calls on your managed object context, allowing you to continue working on the main thread, you can use NSManagedObjectContext's performBlock: method like this:

		// assuming your context is called self.managedObjectContext
		[self.managedObjectContext performBlock:^{
			NSError *error = nil;
        	if (![context save:&error]) {
            	// Code to handle the error appropriately.
        	} else {
            	// Code to handle success.
        	}
		}];
		
	Optionally you can use dispatch queues from Apple's <a href="http://developer.apple.com/library/ios/#documentation/Performance/Reference/GCD_libdispatch_Ref/Reference/reference.html" target="_blank">Grand Central Dispatch</a>. **Important:** You should not perform other methods such as creating, updating or deleting objects on the managed object context while a save is in progress.

<a name="classes_to_check_out">&nbsp;</a>
## Classes To Check Out
* [SMClient](http://stackmob.github.com/stackmob-ios-sdk/Classes/SMClient.html) - Gives you access to everything you need to communicate with StackMob.
* [SMCoreDataStore](http://stackmob.github.com/stackmob-ios-sdk/Classes/SMCoreDataStore.html) -  Gives you access to a configured NSManagedObjectContext communicate with StackMob directly through Core Data.
* [SMDataStore](http://stackmob.github.com/stackmob-ios-sdk/Classes/SMDataStore.html) - Gives you access to make direct REST-based calls to StackMob.
* [SMRequestOptions](http://stackmob.github.com/stackmob-ios-sdk/Classes/SMRequestOptions.html) - When making direct calls to StackMob, an instance of SMRequestOptions gives you request configuration options.
* [SMCustomCodeRequest](http://stackmob.github.com/stackmob-ios-sdk/Classes/SMCustomCodeRequest.html) - Starting place for making custom code calls.
* [SMBinaryDataConversion](http://stackmob.github.com/stackmob-ios-sdk/Classes/SMBinaryDataConversion.html) - Convert NSData to NSString for persisting to a field on StackMob with type Binary Data (s3 Integration).

<a name="tutorials">&nbsp;</a>
## Tutorials
* [Starter App](https://stackmob.com/devcenter/docs/StackMob-iOS-Starter-App)
* [Create an Object](https://stackmob.com/devcenter/docs/StackMob-iOS-Create-Tutorial)
* [Read an Object](https://stackmob.com/devcenter/docs/StackMob-iOS-Read-Tutorial)
* [Read to a Tableview](https://stackmob.com/devcenter/docs/StackMob-iOS-Read-TableView-Tutorial)
* [Update an Object](https://stackmob.com/devcenter/docs/StackMob-iOS-Update-Tutorial)
* [Delete an Object](https://stackmob.com/devcenter/docs/StackMob-iOS-Delete-Tutorial)
* [Create a User Object](https://stackmob.com/devcenter/docs/StackMob-iOS-User-Object-Tutorial)
* [User Authentication](https://stackmob.com/devcenter/docs/StackMob-iOS-User-Authentication-Tutorial)
* [One To One Relationships](https://stackmob.com/devcenter/docs/StackMob-iOS-One-To-One-Relationship-Tutorial)
* [One To Many Relationships](https://stackmob.com/devcenter/docs/StackMob-iOS-One-To-Many-Relationship-Tutorial)

... More coming soon!

<a name="core_data_references">&nbsp;</a>
## Core Data References

* [Getting Started With Core Data](http://www.raywenderlich.com/934/core-data-on-ios-5-tutorial-getting-started) - Ray Wenderlich does a great tutorial on the basics of Core Data.  I would definitely start here.
* [iPhone Core Data: Your First Steps](http://mobile.tutsplus.com/tutorials/iphone/iphone-core-data/) - Well organized tutorial on Core Data.
* [Introduction To Core Data](https://developer.apple.com/library/ios/\#documentation/Cocoa/Conceptual/CoreData/cdProgrammingGuide.html\#//apple\_ref/doc/uid/TP40001075) - Apple's Core Data Programming Guide
* [Introduction To Predicates](https://developer.apple.com/library/ios/\#documentation/Cocoa/Conceptual/Predicates/predicates.html\#//apple\_ref/doc/uid/TP40001789) - Apple's Predicates Programming Guide


<a name="class_index">&nbsp;</a>
## Index





