SHELL := /bin/bash
site:
	rm -rf public/ && \
	git clone https://github.com/fredrikekre/fredrikekre.se public && \
	pushd public && rm -rf * && popd && \
	mkdir -p content && \
	hugo

