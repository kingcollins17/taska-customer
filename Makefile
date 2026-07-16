.PHONY: help setup generate clean build-apk-debug build-apk-release install-apk-debug install-apk-release build-appbundle create-keystore

help:
	@echo "Available commands:"
	@echo "  make setup                - Clean and get dependencies"
	@echo "  make generate             - Run build_runner to generate code"
	@echo "  make clean                - Clean the flutter project"
	@echo "  make build-apk-debug      - Build debug APK"
	@echo "  make build-apk-release    - Build release APK"
	@echo "  make install-apk-debug    - Install debug APK on connected device using adb"
	@echo "  make install-apk-release  - Install release APK on connected device using adb"
	@echo "  make build-appbundle      - Build release AppBundle"
	@echo "  make create-keystore      - Create a keystore for Android release in android/app"

setup:
	flutter clean
	flutter pub get

gen:
	dart run build_runner build -d

clean:
	flutter clean

build-apk-debug:
	flutter build apk --debug

build-apk-release:
	flutter build apk --release

install-apk-debug:
	adb install build/app/outputs/flutter-apk/app-debug.apk

install-apk-release:
	adb install build/app/outputs/flutter-apk/app-release.apk

build-appbundle:
	flutter build appbundle --release

create-keystore:
	keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
