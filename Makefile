.PHONY: gen
gen:
	dart run build_runner build --delete-conflicting-outputs

.PHONY: watch
watch:
	dart run build_runner watch --delete-conflicting-outputs

.PHONY: format
format:
	dart format lib test bin core/lib day_builder/lib
