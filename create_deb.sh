#!/bin/bash

# Set package details
PACKAGE_NAME="hello-world-docker"
VERSION="1.0.0"
ARCH="all"

# Source directory containing app files
SOURCE_DIR="./src"

# Package directory structure
PACKAGE_DIR="${PACKAGE_NAME}_${VERSION}_${ARCH}"
mkdir -p ${PACKAGE_DIR}/usr/local/${PACKAGE_NAME}
mkdir -p ${PACKAGE_DIR}/DEBIAN

# Copy all source files to the package directory
cp -r ${SOURCE_DIR}/* ${PACKAGE_DIR}/usr/local/${PACKAGE_NAME}/

# Create control file for package metadata
cat <<EOF > ${PACKAGE_DIR}/DEBIAN/control
Package: ${PACKAGE_NAME}
Version: ${VERSION}
Section: base
Priority: optional
Architecture: ${ARCH}
Maintainer: Your Name <youremail@example.com>
Description: A Hello World Docker application packaged as a .deb file
EOF

# Create a post-installation script to build and run Docker container
cat <<EOF > ${PACKAGE_DIR}/DEBIAN/postinst
#!/bin/bash
# Build and run the Docker container
cd /usr/local/${PACKAGE_NAME}
docker-compose up -d --build
EOF
chmod +x ${PACKAGE_DIR}/DEBIAN/postinst

# Build the .deb package
dpkg-deb --build ${PACKAGE_DIR}

# Clean up
rm -rf ${PACKAGE_DIR}

echo "${PACKAGE_NAME}_${VERSION}_${ARCH}.deb created successfully."
