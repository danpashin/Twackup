# Twackup

## Description
What is Twackup? Twackup is a simple iOS command line tool that can backup all your installed tweaks from Cydia back to debs.

All you need is to type twackup in terminal. After it finishes, you can pick debs in /var/mobile/Documents/twackup

## How in works?

It scans dpkg output, copies files to temporary folder and build deb. Therefore if you deleted some files from filesystem, they will not be copied to a new deb.

## Licence
Twackup is available under the MIT license. You can see [**LICENSE**](./LICENSE) for more info.
