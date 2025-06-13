# DSpace 9.0

**DSpace** is a widely adopted open-source platform used for building institutional, digital, and academic repositories. It enables organizations to securely and efficiently store, manage, preserve, and share digital resources. With a flexible and scalable architecture, DSpace is utilized by universities, libraries, research labs, and other institutions worldwide to make scientific publications, dissertations, theses, administrative records, datasets, and other types of digital content available.

DSpace supports interoperability standards such as **OAI-PMH** (Open Archives Initiative Protocol for Metadata Harvesting) and **Dublin Core**, facilitating integration with other systems and indexing by academic search engines. It also offers advanced features such as customization, authentication, access control, statistics, and thematic communities.

For more information, visit:

- Official website: [https://dspace.org/](https://dspace.org/)
- Official documentation: [https://wiki.lyrasis.org/display/DSDOC9x/DSpace+9.x+Documentation](https://wiki.lyrasis.org/display/DSDOC9x/DSpace+9.x+Documentation)

> *This project is based on the official DSpace images with modifications and production-ready adaptations for the backend and Angular frontend containers, along with an NGINX container acting as a load balancer.*

---

## Directory Structure

```
├── certs/                  # Contains certificates used by the web server
│   ├── dhparam.pem         # Can be generated with: openssl dhparam -out dhparam.pem 2048
│   ├── example.org.crt     # Institution's certificate
│   └── example.org.key     # Institution's private key
│
├── config/                 # Configuration files for dspace-angular, nginx, and hosts file
│   ├── config.prod.yml     # dspace-angular configuration file
│   ├── dspace-ui.json      # PM2 configuration file for dspace-angular
│   ├── hosts               # Hosts file for DNS resolution between containers
│   └── nginx.conf          # Load balancer configuration
│
├── docker-compose.yml      # Docker Compose deployment configuration
├── Dockerfile-backend      # Dockerfile for building the backend image
├── Dockerfile-frontend     # Dockerfile for building the frontend image
├── letsencrypt-certs-generate.sh # Script to generate Let's Encrypt certificates (optional)
├── README.md               # This documentation
└── src/
    └── dspace/             # DSpace backend application files
        ├── bin/
        │   └── dspace      # CLI tool for administrative tasks
        └── config/
            ├── dspace.cfg            # Default configuration file (do not modify)
            ├── local.cfg             # Custom configuration file (overrides dspace.cfg)
            ├── local.cfg.EXAMPLE    # Example configuration file
            └── modules/              # Module-specific configuration files:
                ├── authentication.cfg
                ├── authentication-ip.cfg
                ├── authentication-ldap.cfg
                ├── authentication-oidc.cfg
                ├── authentication-password.cfg
                ├── authentication-saml.cfg
                ├── authentication-shibboleth.cfg
                └── authentication-x509.cfg
```

---

## Container Structure

- **dspace** – Backend container, built from the official DSpace Dockerfile with production modifications.
- **dspacedb** – PostgreSQL container provided by the official DSpace project.
- **dspacesolr** – Solr container provided by the official DSpace project.
- **dspace-angular** – Frontend container, built from the official DSpace Angular Dockerfile with production modifications.
- **nginx** – Official NGINX image customized as a secure load balancer.

---

## Knowledge Base and Troubleshooting

- In `local.cfg`, the line `dspace.server.url` **must be configured with HTTPS** using a **domain name**, not an IP address. Example: `https://test.example.org/server`
- In `config.prod.yml`, the `rest` block must be configured with **SSL enabled**, using the domain name and port 443. Using an IP address will result in errors when `production=true`.

---

## Sample Backend Configuration (`local.cfg`)

```properties
# DSpace root directory
dspace.dir=/dspace

# Backend URL (must use HTTPS and domain name, no trailing slash)
dspace.server.url = https://test.example.org/server

# Frontend (Angular) URL (must use domain, HTTP only, no trailing slash)
dspace.ui.url = http://test.example.org

# Institution name
dspace.name = My Organization Example

# Database connection
db.url = jdbc:postgresql://dspacedb:5432/dspace
db.username = dspace
db.password = dspace

# LDAP authentication plugin
plugin.sequence.org.dspace.authenticate.AuthenticationMethod = org.dspace.authenticate.LDAPAuthentication

# Password authentication plugin
plugin.sequence.org.dspace.authenticate.AuthenticationMethod = org.dspace.authenticate.PasswordAuthentication,org.dspace.authenticate.LDAPAuthentication
```

## Sample Frontend Configuration (`config.prod.yml`)

```yaml
ui:
  ssl: false
  host: dspace-angular
  port: 4000
  nameSpace: /
rest:
  ssl: true
  host: test.example.org
  port: 443
  nameSpace: /server
```

## PM2 Configuration (`dspace-ui.json`)

```json
{
  "apps": [
    {
      "name": "dspace-ui",
      "cwd": "/app",
      "script": "dist/server/main.js",
      "instances": "max",
      "exec_mode": "cluster",
      "env": {
        "NODE_ENV": "production"
      }
    }
  ]
}
```

## Environment File

```
cat .env
# PostgreSQL configuration
POSTGRES_PASSWORD=dspace
```

---

## Let's Encrypt

The NGINX container is configured to be used with your own certificates generated from a CA by default, but the project can be adapted to use **Let's Encrypt**.

1. Ensure the DNS is configured properly:

   - Example: `test.example.org` should resolve to `172.16.0.10` (DSpace server IP)

2. The web server must respond to `http://test.example.org/.well-known/acme-challenge/`

3. Generate the certificates:

```bash
docker compose up -d nginx

# Review the script variables:
cat letsencrypt-certs-generate.sh
DOMAIN='test.example.org'
EMAIL='youremail@example.org'

# Run the script:
./letsencrypt-certs-generate.sh
```

4. Update `docker-compose.yml` and uncomment the Certbot service.

5. Modify `nginx.conf` to use Let's Encrypt certificates:

```nginx
ssl_certificate     /etc/letsencrypt/live/test.example.org/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/test.example.org/privkey.pem;
```

---

## Deploy DSpace

You can deploy the environment with a single command:

```bash
docker compose up -d
```

Optionally, build your custom images before running the containers:

```bash
docker image build -t registry.example.org/dspace:9.0 -f Dockerfile-backend .
docker image build -t registry.example.org/dspace-angular:9.0 -f Dockerfile-frontend .
```

---

## Creating an Administrator User

DSpace does **not** include a default admin user. You must create one manually:

```bash
# Access the backend container
docker container exec -ti dspace bash

# Create the admin user
/dspace/bin/dspace create-administrator
```

---

## History

**June 13, 2025 – Emanuel Ramos**\
Initial commit.

