SHELL := /bin/bash
JULIA := julia --project=build-tools -L build-tools/L.jl

clean:
	rm -rf __site
optimize: clean franklin-image
	${JULIA} -e 'Franklin.optimize(minify=false)'
# 	docker run -v ${PWD}/__site:/__site franklin-minify
	cp -nr static/* __site/
build: clean
	${JULIA} -e 'Franklin.serve(single=true)'
	cp -nr static/* __site/
serve: clean
	${JULIA} -e 'Franklin.serve(; host="0.0.0.0")'
lserve: optimize
	${JULIA} -e 'LiveServer.serve(dir="__site")'
deploy: optimize
	# TODO: Make sure everything is committed.
	mkdir -p gh-pages
	rm -r gh-pages/*
	cp -r __site/* gh-pages/
	git -C gh-pages commit -am "Webpage update $(date --utc -Isecond), commit $(git show -s --format=%h)."

franklin-image:
	@if ! docker image ls | grep --quiet franklin-minify ; then \
		echo "BUILDING"; \
		docker build -f build-tools/minify-docker/Dockerfile -t franklin-minify build-tools/minify-docker/; \
	fi

.PHONY: clean optimize build serve lserve franklin-image deploy
