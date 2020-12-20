# Web Monitor

Command line tool to monitor a URL for changes and shows the diff. Specially useful to monitor news websites.

## Build

```
docker build -t webmonitor .
```

## Run

```
docker run webmonitor "https://www.nytimes.com"
```
