FROM alpine
RUN apk add --update python3 py3-pip && \
    pip3 install --upgrade pip && \
    pip3 install css_html_js_minify
COPY ./minify.py /script/minify.py
ENTRYPOINT python3 /script/minify.py
