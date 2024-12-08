.PHONY: gen
gen:
	dart run build_runner build --delete-conflicting-outputs

.PHONY: watch
watch:
	dart run build_runner watch --delete-conflicting-outputs

.PHONY: format
format:
	dart format bin lib test tool core/lib core/test day_builder/lib
