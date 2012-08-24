## StackMob iOS SDK Changelog

### 1.0.0beta.3

* Fix bug so save: to the managed object context will return NO if StackMob calls fail.
* Fix bug where fetch requests not returning errors.

### 1.0.0beta.2

* Performing custom code methods is now available through the `SMCustomCodeRequest` class.
* Binary Data can be converted into an NSString using the `SMBinaryDataConversion` class and persisted to a StackMob field with Binary Data type.


### 1.0.0beta.1

* Initial release of new and improved iOS SDK.  Core Data integration serves as the biggest change to the way developers interact with the SDK. See [iOS SDK v1.0 beta](https://www.stackmob.com/devcenter/docs/iOS-SDK-v1.0-beta) for more information. 