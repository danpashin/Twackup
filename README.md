# Twackup

## Description
What is Twackup? Twackup is a simple iOS command line tool that can backup all your installed tweaks from Cydia back to debs.

All you need is to type `twackup -a` in terminal. After it finishes, you can pick debs in /var/mobile/Documents/twackup

## How it works?

It scans dpkg output, copies files to temporary folder and build deb. Therefore if you deleted some files from filesystem, they will not be copied to a new deb.

##How to build?
Ensure you have CocoaPods installed. If not, install it using command:

`sudo gem install cocoapods`

Then clone the repository and install dependencies:

```
git clone https://github.com/danpashin/Twackup.git
cd Twackup
pod install
open Twackup.xcworkspace
```

## Licence
Twackup is available under the MIT license. You can see [**LICENSE**](./LICENSE) for more info.
