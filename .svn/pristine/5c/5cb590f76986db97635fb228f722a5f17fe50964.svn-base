#!/bin/bash

xcodebuild -configuration Release -target WhistleIm SYMROOT=~/Build/WhistleIm/Sym.root

cd ~/Build/WhistleIm/Sym.root
mkdir -p ipa/Payload
cp -r ./Release-iphoneos/WhistleIm.app ./ipa/Payload/
cd ipa
zip -r WhistleIm.ipa *
