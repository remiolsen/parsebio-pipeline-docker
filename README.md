# Parsebio-pipeline-docker

## Disclaimer

This software and the author of this repository are in no way affiliated with, endorsed by, or sponsored by Parse Biosciences or QIAGEN. All trademarks, product names or company names cited herein are the property of their respective owners. Use of these names does not imply any affiliation or endorsement. This software is provided "as is", without warranty of any kind.

## Prerequisites

Pipeline files needs to be obtained from the vendor behind a registration-wall:

```
ParseBiosciences-Pipeline.1.7.1.zip (currently supported)
md5: 6ebe50fa3512d91a88215decfbacfa82
```

## Building

Step 1. Obtain the software from the vendor in form of a .zip file (e.g. version 1.7.1)

Step 2. Run:
```
docker build \
  --build-arg PIPELINE_VERSION=1.7.1 \
  --build-arg IMAGE_VERSION=0.0.1 \
  -t parsebio-pipeline:1.7.1-0.0.1 \
  .
```