#!/bin/bash

# -----------------------------------------------------------------------------
# Script to deploy a Splunk instance in HTTPS with self-signed certificates
# using Docker Compose.
# -----------------------------------------------------------------------------

set -e

# vars

PROJECT_DIR="splunk-https-docker"
SPLUNK_HOSTNAME="splunk.docker.local"
CERT_DIR="${PROJECT_DIR}/certs"
CONFIG_DIR="${PROJECT_DIR}/splunk_config/local"

# colors

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

check_dependencies() {
    for cmd in docker docker-compose openssl; do
        if ! command -v $cmd &> /dev/null; then
            echo -e "${YELLOW}Error: '$cmd' is not installed. Please install it first.${NC}"
            exit 1
        fi
    done
}

create_structure() {
    mkdir -p "$CERT_DIR"
    mkdir -p "$CONFIG_DIR"
}

generate_certs() {
    openssl req -x509 \
      -newkey rsa:4096 \
      -keyout "${CERT_DIR}/splunk.key" \
      -out "${CERT_DIR}/splunk.pem" \
      -days 365 \
      -nodes \
      -subj "/C=FR/ST=Paris/L=Paris/O=Dev/CN=${SPLUNK_HOSTNAME}"
    cat "${CERT_DIR}/splunk.key" "${CERT_DIR}/splunk.pem" > "${CERT_DIR}/splunk.pem"
}

create_config_files() {
    cat <<EOF > "${CONFIG_DIR}/web.conf"
[settings]
enableSplunkWebSSL = true
privKeyPath = /opt/splunk/etc/auth/mycerts/splunk_combined.pem
serverCert = /opt/splunk/etc/auth/mycerts/splunk_combined.pem
EOF

    cat <<EOF > "${PROJECT_DIR}/docker-compose.yml"
version: '3.8'

services:
  splunk:
    image: splunk/splunk:latest
    container_name: splunk
    hostname: ${SPLUNK_HOSTNAME}
    environment:
      - SPLUNK_START_ARGS=--accept-license
      - SPLUNK_PASSWORD=${SPLUNK_ADMIN_PASSWORD}
    ports:
      - "8000:8000"
      - "8088:8088"
      - "8089:8089"
    volumes:
      - ./certs:/opt/splunk/etc/auth/mycerts
      - ./splunk_config/local:/opt/splunk/etc/system/local
      - splunk-data:/opt/splunk/var

volumes:
  splunk-data:
    driver: local
EOF
}

if [ -f "${PROJECT_DIR}/docker-compose.yml" ]; then
    echo -e "${YELLOW}Existing deployment found.${NC}"
    read -p "Do you want to stop and remove the existing deployment before continuing? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        (cd "$PROJECT_DIR" && docker-compose down -v --remove-orphans)
        rm -rf "$PROJECT_DIR"
    else
        echo -e "${YELLOW}Operation cancelled by user.${NC}"
        exit 0
    fi
fi

check_dependencies

while true; do
    read -sp "Enter the password for Splunk 'admin' user: " SPLUNK_ADMIN_PASSWORD
    echo
    if [ -z "$SPLUNK_ADMIN_PASSWORD" ]; then
        echo -e "${YELLOW}Password cannot be empty. Please try again.${NC}"
    else
        break
    fi
done

create_structure
generate_certs
create_config_files

echo -e "\n${BLUE}Starting Splunk container with Docker Compose...${NC}"
echo -e "${YELLOW}First startup may take a few minutes.${NC}"

(cd "$PROJECT_DIR" && docker-compose up -d)

echo -e "\n${GREEN}====================================================="
echo -e "🎉 Splunk has been successfully deployed! 🎉"
echo -e "=====================================================${NC}"
echo -e "Access URL : ${GREEN}https://localhost:8000${NC}"
echo -e "Username   : ${GREEN}admin${NC}"
echo -e "Password   : ${GREEN}The one you just set.${NC}"
echo -e "\n${YELLOW}NOTE: Your browser will show a security warning."
echo -e "This is normal because the certificate is self-signed. Accept the risk to continue.${NC}"
echo -e "\nTo view logs: ${BLUE}cd ${PROJECT_DIR} && docker-compose logs -f${NC}"
echo -e "To stop Splunk: ${BLUE}cd ${PROJECT_DIR} && docker-compose down${NC}"
echo -e "To stop and remove data: ${BLUE}cd ${PROJECT_DIR} && docker-compose down -v${NC}"
