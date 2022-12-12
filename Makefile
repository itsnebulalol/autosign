.PHONY: build

build:
	@rm -rf packages
	@mkdir packages
	@dpkg-deb -b src packages/