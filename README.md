# hermetic-build

Provides all the relevant tools for showcasing the hermetic builds concept.

## Getting started

### Build the base image (ARM64)

```bash
docker build -f cpp/build/base-image.dockerfile \
  --platform=linux/arm64 \
  --build-arg="TARGET_ARCH=arm64" \
  -t hermetic-demo:1.0.0 .
```

### Build the base image (x64)

```bash
docker build -f cpp/build/base-image.dockerfile \
  --platform=linux/amd64 \
  --build-arg="TARGET_ARCH=amd64" \
  -t hermetic-demo:1.0.0 .
```

### Start the remote development

```bash
chmod u+x ./cpp/build/run-remote-development.sh
./cpp/build/run-remote-development.sh
```

You can now use your preferred IDE with remote toolchain support. SSH connectivity can be achieved over 127.0.0.1:2222.

Credentials are:

```
Username: root
Password: test
```