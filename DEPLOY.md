# Deployment (docker-compose-next)

This document explains how to run the dashboard stack from prebuilt images published to GHCR.

`docker-compose-next.yaml` is intended for deployment only. It does not build images locally.

1. Prepare image tags and repository

- Choose the image tag to deploy (`IMAGE_TAG`), for example:
  - `latest`
  - a git SHA
  - a release tag
- Set registry owner/repo variables:
- `IMAGE_REGISTRY` (defaults to `ghcr.io` if not set)
- `IMAGE_OWNER` (required for local deployment)
- `IMAGE_REPOSITORY` (required for local deployment)

Example:

```bash
export IMAGE_REGISTRY=ghcr.io
export IMAGE_OWNER=<your-gh-user-or-org>
export IMAGE_REPOSITORY=<your-repo-name>
export IMAGE_TAG=<tag>
```

2. Set environment files

- Create the three required env files from examples:
  - `.env.db`
  - `.env.backend`
  - `.env.proxy`
- Ensure `DB_DEFAULT_PASSWORD` is set in `.env.backend`.
- If you keep the local PostgreSQL service, you can leave `DB_DEFAULT_HOST` unset and use the default (`dashboard_db`).
- If you connect to an external DB, set `DB_DEFAULT_HOST` to that host.

3. Authenticate to GHCR

```bash
docker login ghcr.io
```

4. Deploy

```bash
docker compose -f docker-compose-next.yaml pull
docker compose -f docker-compose-next.yaml up -d
```

5. Useful checks

- View logs:

```bash
docker compose -f docker-compose-next.yaml logs -f
```

- Stop stack:

```bash
docker compose -f docker-compose-next.yaml down
```

6. Notes

- `cloudsql-proxy` service was removed from this compose file. If you need Cloud SQL, deploy it separately or keep using your existing local/infra-specific setup.
- This compose file expects these services:
  - `dashboard_db`
  - `redis`
  - `backend`
  - `dashboard`
  - `proxy`
- Static files are shared through the `static-data` volume and are expected to be written by the `dashboard` image.
- For private GHCR repos, repository secrets/tokens are required at runtime for `docker login`.
