APP_DIR := .
ANDROID_INSTALL_ARCH ?= arm64-v8a
ANDROID_RELEASE_APK := $(APP_DIR)/android/app/build/outputs/apk/release/app-release.apk
IOS_SCHEME := swiftycompanion
IOS_DERIVED_DATA := $(APP_DIR)/ios/build
IOS_RELEASE_APP := $(IOS_DERIVED_DATA)/Build/Products/Release-iphoneos/$(IOS_SCHEME).app

.PHONY: install start android ios run-android run-ios web android-release-build android-release-install android-release-apk ios-release-build ios-release-install ios-sim-build ios-sim-install dev clean

install:
	cd $(APP_DIR) && npm install

start:
	cd $(APP_DIR) && npx expo start

android:
	cd $(APP_DIR) && npx expo start --android

ios:
	cd $(APP_DIR) && npx expo start --ios

run-android:
	cd $(APP_DIR) && npx expo run:android --device

run-ios:
	cd $(APP_DIR) && npx expo run:ios

ios-release-build:
	cd $(APP_DIR)/ios && xcodebuild -workspace $(IOS_SCHEME).xcworkspace -scheme $(IOS_SCHEME) -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' -derivedDataPath build build

ios-release-install: ios-release-build
	@UDID=$$(xcrun devicectl list devices --json-output - 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); c=[x for x in d['result']['devices'] if x.get('connectionProperties',{}).get('tunnelState')=='connected' and x.get('hardwareProperties',{}).get('reality')=='physical']; print(c[0]['identifier']) if c else sys.exit(1)"); \
	if [ -z "$$UDID" ]; then echo "No connected physical iOS device found. Plug in and unlock your iPhone."; exit 1; fi; \
	echo "Installing to device $$UDID"; \
	xcrun devicectl device install app --device $$UDID $(IOS_RELEASE_APP)

ios-sim-build:
	cd $(APP_DIR)/ios && xcodebuild -workspace $(IOS_SCHEME).xcworkspace -scheme $(IOS_SCHEME) -configuration Release -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath build-sim build

ios-sim-install: ios-sim-build
	@UDID=$$(xcrun simctl list devices booted -j 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(next(iter([dd['udid'] for r in d['devices'].values() for dd in r if dd.get('state')=='Booted']), ''))"); \
	if [ -z "$$UDID" ]; then echo "No booted simulator found. Boot one first (e.g. xcrun simctl boot <udid>)."; exit 1; fi; \
	echo "Installing to simulator $$UDID"; \
	xcrun simctl install $$UDID $(IOS_DERIVED_DATA)-sim/Build/Products/Release-iphonesimulator/$(IOS_SCHEME).app; \
	xcrun simctl launch $$UDID com.rperezt.swifty-companion

web:
	cd $(APP_DIR) && npx expo start --web

android-release-build:
	cd $(APP_DIR)/android && ./gradlew assembleRelease

android-release-install:
	cd $(APP_DIR)/android && ./gradlew assembleRelease -PreactNativeArchitectures=$(ANDROID_INSTALL_ARCH)
	adb install -r $(ANDROID_RELEASE_APK)

android-release-apk:
	@echo "$(ANDROID_RELEASE_APK)"

dev:
	cd $(APP_DIR) && npx expo run:android --device

clean:
	cd $(APP_DIR) && rm -rf node_modules .expo
