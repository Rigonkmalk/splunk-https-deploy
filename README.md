# Splunk HTTPS Docker Deployment Script

This repository provides a simple shell script to deploy a Splunk instance in a Docker container, accessible via HTTPS with a self-signed certificate.

## Features

- **Automated setup:** No manual steps required.
- **Self-signed SSL:** Secure Splunk Web with HTTPS.
- **Password prompt:** Set your own Splunk admin password securely.
- **Easy cleanup:** Option to remove previous deployments.

## Prerequisites

- [Docker](https://www.docker.com/) installed
- [Docker Compose](https://docs.docker.com/compose/) installed
- [OpenSSL](https://www.openssl.org/) installed
- Bash shell

## Usage

1. **Download the script**

   Save the script as `deploy_splunk.sh` in your working directory.

2. **Make the script executable**

   ```bash
   chmod +x deploy_splunk.sh
   ```

3. **Run the script**

   ```bash
   ./deploy_splunk.sh
   ```

   - You will be prompted to enter a password for the Splunk `admin` user.
   - The script will create all necessary files and start Splunk in a Docker container.

4. **Access Splunk**

   - Open your browser and go to: [https://localhost:8000](https://localhost:8000)
   - Username: `admin`
   - Password: The one you set during the script execution.
   - **Note:** Your browser will show a security warning because the certificate is self-signed. Accept the risk to continue.

## Managing Splunk

- **View logs:**
  ```bash
  cd splunk-https-docker
  docker-compose logs -f
  ```

- **Stop Splunk:**
  ```bash
  cd splunk-https-docker
  docker-compose down
  ```

- **Stop and remove all data:**
  ```bash
  cd splunk-https-docker
  docker-compose down -v
  ```

## Cleanup

To remove the deployment, simply delete the `splunk-https-docker` directory.

---

**Enjoy your secure Splunk instance!**
