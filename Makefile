.PHONY: bootstrap format analyze test web quality

bootstrap:
	flutter pub get
	flutter gen-l10n

format:
	dart format .

analyze:
	flutter analyze

test:
	flutter test

web:
	flutter build web --release

quality:
	dart format --output=none --set-exit-if-changed .
	flutter analyze
	flutter test
