# Welcome to the StackMob iOS SDK Documentation!

### Current Version: 1.0.0beta.2


## Overview

The goal of the iOS SDK is to provide the best experience possible for developing an application that uses StackMob as a cloud backend.  

### How is the new iOS SDK different from the older version? 

The biggest difference between the new and the current SDKs is our use of Core Data as a foundation for the new SDK. We believe Core Data is a better approach for integrating StackMob’s REST based API into an iOS application.

We've also separated our Push Notification API into a separate SDK. For more information, see the [iOS Push SDK Reference](http://stackmob.github.com/stackmob-ios-push-sdk/index.html).

### Why base the new SDK on Core Data? 
Our number one goal is to create a better experience. Core Data allows us to place a familiar wrapper around StackMob REST calls and datastore API. iOS developers can leverage their existing knowledge of Core Data to quickly integrate StackMob into their applications.  For those interested in sticking to the REST-based way of making requests, we provide the full data store API.

### Reporting issues or feature requests  

You can file issues through the [GitHub issue tracker](https://github.com/stackmob/stackmob-ios-sdk/issues).


### Still have questions about the new iOS SDK? 

Email us at [support@stackmob.com](mailto:support@stackmob.com).

## Getting Started

If you don't already have the StackMob SDK imported into your application, [get started with StackMob](https://stackmob.com/platform/start).

**The fundamental class for StackMob is SMClient**.  From an instance of this class you have access to a configured managed object context and persistent store coordinator as well as a REST-based data store. Check out the [class reference for SMClient](http://stackmob.github.com/stackmob-ios-sdk/Classes/SMClient.html) for more information.  Let's see how to initialize our `SMClient`:

### Initialize your SMClient

Wherever you plan to use StackMob, add `#import "StackMob.h"` to the header file.

Create a variable of class `SMClient`, most likely in your AppDelegate file where you initialize other application wide variables, and initalize it like this:

	// Assuming your variable is decalred SMClient *client;
	client = [[SMClient alloc] initWithAPIVersion:<api_version> publicKey:<public_key>];
	
If you haven't found your public key yet, check out **Manage App Info** under the **App Settings** sidebar on the [Platform page](https://stackmob.com/platform).
	
### Start persisting data

There are two ways to persist data to StackMob:

* Core Data
* Lower Level Datastore API

#### Core Data


StackMob recommends using Core Data… it provides a powerful and robust object graph management system that otherwise would be a nightmare to implement.  Although it may have a reputation for being pretty complex, the basics are easy to grasp and understanding.  If you want to learn the basics, check out **Core Data References** below.

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
	
Use this instance of NSManagedObjectContext throughout your application.

#### Lower Level Datastore API

If you want to make direct REST-based calls to the datastore, grab an instance of SMDataStore like this:

	SMDataStore *dataStore = [client dataStore];
	
Check out [SMDataStore](http://stackmob.github.com/stackmob-ios-sdk/Classes/SMDataStore.html) for all available methods.

## Classes To Check Out
* [SMClient](http://stackmob.github.com/stackmob-ios-sdk/Classes/SMClient.html) - Gives you access to everything you need to communicate with StackMob.
* [SMCoreDataStore](http://stackmob.github.com/stackmob-ios-sdk/Classes/SMCoreDataStore.html) -  Gives you access to a configured NSManagedObjectContext communicate with StackMob directly through Core Data.
* [SMDataStore](http://stackmob.github.com/stackmob-ios-sdk/Classes/SMDataStore.html) - Gives you access to make direct REST-based calls to StackMob.
* [SMRequestOptions](http://stackmob.github.com/stackmob-ios-sdk/Classes/SMRequestOptions.html) - When making direct calls to StackMob, an instance of SMRequestOptions gives you request configuration options.
* [SMCustomCodeRequest](http://stackmob.github.com/stackmob-ios-sdk/Classes/SMCustomCodeRequest.html) - Starting place for making custom code calls.
* [SMBinaryDataConversion](http://stackmob.github.com/stackmob-ios-sdk/Classes/SMBinaryDataConversion.html) - Convert NSData to NSString for persisting to a field on StackMob with type Binary Data (s3 Integration).

## Tutorials
* [Your First StackMob Application](https://stackmob.com/devcenter/docs/StackMob-iOS-SDK-Tutorial)

## Core Data References

* [Getting Started With Core Data](http://www.raywenderlich.com/934/core-data-on-ios-5-tutorial-getting-started) - Ray Wenderlich does a great tutorial on the basics of Core Data.  I would definitely start here.
* [iPhone Core Data: Your First Steps](http://mobile.tutsplus.com/tutorials/iphone/iphone-core-data/) - Well organized tutorial on Core Data.
* [Introduction To Core Data](https://developer.apple.com/library/ios/\#documentation/Cocoa/Conceptual/CoreData/cdProgrammingGuide.html\#//apple\_ref/doc/uid/TP40001075) - Apple's Core Data Programming Guide
* [Introduction To Predicates](https://developer.apple.com/library/ios/\#documentation/Cocoa/Conceptual/Predicates/predicates.html\#//apple\_ref/doc/uid/TP40001789) - Apple's Predicates Programming Guide



## Index





