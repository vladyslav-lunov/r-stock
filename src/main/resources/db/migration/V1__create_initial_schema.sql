CREATE TYPE subscription_plan AS ENUM ('FREE', 'PREMIUM');
CREATE TYPE order_status AS ENUM ('PENDING', 'IN_PROGRESS', 'COMPLETE', 'CANCELED');
CREATE TYPE users_role AS ENUM ('OWNER', 'MANAGER', 'STAFF', 'ADMIN');
CREATE TYPE location_type AS ENUM ('STORE', 'WAREHOUSE');

CREATE TABLE tenant
(
    id           UUID PRIMARY KEY           DEFAULT gen_random_uuid(),
    name         VARCHAR(255)      NOT NULL UNIQUE,
    subscription subscription_plan NOT NULL DEFAULT 'FREE',
    created_at   TIMESTAMPTZ       NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ
);

CREATE TABLE users
(
    id         UUID PRIMARY KEY      DEFAULT gen_random_uuid(),
    first_name VARCHAR(255) NOT NULL,
    last_name  VARCHAR(255) NOT NULL,
    email      VARCHAR(255) NOT NULL UNIQUE,
    role       users_role   NOT NULL,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    tenant_id  UUID         NOT NULL REFERENCES tenant (id) ON DELETE CASCADE
);

CREATE TABLE address
(
    id           UUID PRIMARY KEY      DEFAULT gen_random_uuid(),
    country      VARCHAR(255) NOT NULL,
    city         VARCHAR(255) NOT NULL,
    street       VARCHAR(255) NOT NULL,
    house_number VARCHAR(60)  NOT NULL,
    postal_code  VARCHAR(60)  NOT NULL,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ
);

CREATE TABLE location
(
    id         UUID PRIMARY KEY       DEFAULT gen_random_uuid(),
    name       VARCHAR(255)  NOT NULL,
    type       location_type NOT NULL,
    tenant_id  UUID          NOT NULL REFERENCES tenant (id),
    address_id UUID          NOT NULL REFERENCES address (id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    UNIQUE (tenant_id, name)
);

CREATE TABLE category
(
    id         UUID PRIMARY KEY      DEFAULT gen_random_uuid(),
    name       VARCHAR(255) NOT NULL,
    tenant_id  UUID         NOT NULL REFERENCES tenant (id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    UNIQUE (tenant_id, name)
);

CREATE TABLE product
(
    id          UUID PRIMARY KEY      DEFAULT gen_random_uuid(),
    tenant_id   UUID         NOT NULL REFERENCES tenant (id) ON DELETE CASCADE,
    category_id UUID         REFERENCES category (id) ON DELETE SET NULL,
    sku         VARCHAR(100) NOT NULL,
    name        VARCHAR(255) NOT NULL,
    description TEXT         NOT NULL DEFAULT 'Description has not been added yet.',
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    UNIQUE (tenant_id, sku)
);

CREATE TABLE users_location
(
    user_id     UUID NOT NULL REFERENCES users (id),
    location_id UUID NOT NULL REFERENCES location (id)
);



CREATE INDEX idx_users_tenant ON users (tenant_id);
CREATE INDEX idx_category_tenant ON category (tenant_id);
CREATE INDEX idx_product_tenant ON product (tenant_id);
CREATE INDEX idx_product_tenant_name ON product (tenant_id, name);
CREATE INDEX idx_product_tenant_category ON product (tenant_id, category_id);