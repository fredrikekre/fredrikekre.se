SHELL := /bin/bash
JULIA := julia --project=build-tools -L build-tools/L.jl

donothing:

clean:
	rm -rf __site
optimize: clean franklin-image
	FRANKLIN_OPTIMIZE=true \
	${JULIA} -e 'Franklin.optimize(; minify=false, on_write=on_write)'
# 	docker run -v ${PWD}/__site:/__site franklin-minify
	cp -nr static/* __site/
serve: clean
	${JULIA} -e 'Franklin.serve(; host="0.0.0.0", on_write=on_write)'
lserve: optimize
	${JULIA} -e 'LiveServer.serve(; dir="__site", host="0.0.0.0")'
stage: optimize
	# TODO: Make sure everything is committed.
	mkdir -p gh-pages
	rm -r gh-pages/*
	cp -r __site/* gh-pages/
commit:
	git -C gh-pages commit -m "Webpage update $(date --utc -Isecond), commit $(git show -s --format=%h)."
push:
	git -C gh-pages push origin gh-pages

franklin-image:
	@if ! docker image ls | grep --quiet franklin-minify ; then \
		echo "BUILDING"; \
		docker build -f build-tools/minify-docker/Dockerfile -t franklin-minify build-tools/minify-docker/; \
	fi

.PHONY: clean optimize build serve lserve franklin-image stage commit
