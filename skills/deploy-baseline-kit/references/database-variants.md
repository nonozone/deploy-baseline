# Database Variants

Use this reference whenever the project has persistence, env vars, ORM config, or deployment scripts that imply a database choice.

## Detection order

Inspect these sources:

1. Compose services
2. env examples and deploy env files
3. app config and ORM config
4. dependencies and lockfiles
5. README or deployment docs

## Common signals

### PostgreSQL

Signals:

- `postgres` images or services
- `pg_isready`
- ports `5432`
- env names like `POSTGRES_USER` or `DATABASE_URL` with `postgres://`

Default baseline:

- if and only if PostgreSQL is the confirmed target database, use `postgres:18-alpine` for new baseline generation

For existing projects:

- do not auto-upgrade blindly
- decide whether to keep the current version, recommend upgrade, or change after confirmation

### PostgreSQL major-version caveats

Check for version-specific deployment differences before converging compose mounts or docs.

Examples:

- PostgreSQL 18 image behavior around `VOLUME /var/lib/postgresql`
- whether `PGDATA` must be set explicitly
- whether old mount paths such as `/var/lib/postgresql/data` should be replaced with `/var/lib/postgresql`

For existing projects:

- do not blindly preserve old mount targets when the project already upgraded major PostgreSQL versions
- verify persistence strategy with `docker compose config` and document the chosen path

### MySQL or MariaDB

Signals:

- `mysql`, `mariadb`, or port `3306`
- env names like `MYSQL_DATABASE`, `MYSQL_USER`

Action:

- keep the same family unless the project explicitly indicates otherwise
- adapt env examples, healthchecks, volumes, and docs to that family

Version caveats:

- check for major-version authentication plugin differences
- verify any image-specific startup flags before converging compose

### MongoDB

Signals:

- `mongo`, `mongod`, or port `27017`
- env names like `MONGO_INITDB_ROOT_USERNAME`

Action:

- do not force SQL-oriented env naming or healthcheck wording onto the project

Version caveats:

- verify major-version startup flag differences before changing command or persistence options

### External database

Signals:

- no DB service in Compose
- env points to managed services
- docs mention RDS, Cloud SQL, Atlas, Supabase, or similar

Action:

- do not add a local DB container unless the developer explicitly asks for one
- still document env sourcing, startup contract, and deployment checks

### Unknown database

If the project is new or detection is inconclusive:

- ask the developer to confirm database type in the single confirmation message
- do not silently default to PostgreSQL
- do not silently omit the database decision
