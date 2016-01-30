# Brundlefly for iOS

[![CI Status](http://img.shields.io/travis/James Ayvaz/Brundlefly.svg?style=flat)](https://travis-ci.org/James Ayvaz/Brundlefly)
[![Version](https://img.shields.io/cocoapods/v/Brundlefly.svg?style=flat)](http://cocoapods.org/pods/Brundlefly)
[![License](https://img.shields.io/cocoapods/l/Brundlefly.svg?style=flat)](http://cocoapods.org/pods/Brundlefly)
[![Platform](https://img.shields.io/cocoapods/p/Brundlefly.svg?style=flat)](http://cocoapods.org/pods/Brundlefly)

A reverse engineered version of the animation library used in Google Photos.  
This library works by reading a JSON file exported from Adobe After effects
and creates view and animations as specified.  The animations are done using native views and
animators.

<img src="docs/device.gif" width="360" height="640">


## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

### CocoaPods

Brundlefly is available through [CocoaPods](http://cocoapods.org).

Install CocoaPods if not already available:

``` bash
$ [sudo] gem install cocoapods
$ pod setup
```

Change to the directory of your Xcode project:

``` bash
$ cd /path/to/MyProject
$ touch Podfile
$ edit Podfile
```

Edit your Podfile and add Brundlefly:

``` bash
platform :ios, '8.0'
pod 'Brundlefly'
```

Install into your Xcode project:

``` bash
$ pod install
```

Open your project in Xcode from the .xcworkspace file (not the usual project file)

``` bash
$ open MyProject.xcworkspace
```

## Author

James Ayvaz, james.ayvaz@gmail.com

## License

Brundlefly is available under the MIT license. See the LICENSE file for more info.
