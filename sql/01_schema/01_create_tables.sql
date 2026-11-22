DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id    VARCHAR(20)  PRIMARY KEY,
    customer_name  VARCHAR(100) NOT NULL,
    segment        VARCHAR(20)  NOT NULL
        CHECK (segment IN ('Consumer', 'Corporate', 'Home Office'))
);

CREATE TABLE products (
    product_key    INTEGER      PRIMARY KEY,
    product_id     VARCHAR(30)  NOT NULL,
    product_name   VARCHAR(255) NOT NULL,
    category       VARCHAR(30)  NOT NULL,
    sub_category   VARCHAR(30)  NOT NULL,
    UNIQUE (product_id, product_name)
);

CREATE TABLE orders (
    order_id       VARCHAR(20)  PRIMARY KEY,
    customer_id    VARCHAR(20)  NOT NULL REFERENCES customers (customer_id),
    order_date     DATE         NOT NULL,
    ship_date      DATE         NOT NULL,
    ship_mode      VARCHAR(20)  NOT NULL,
    country        VARCHAR(40)  NOT NULL,
    state          VARCHAR(40)  NOT NULL,
    city           VARCHAR(60)  NOT NULL,
    postal_code    CHAR(5)      NOT NULL,
    region         VARCHAR(20)  NOT NULL,
    CHECK (ship_date >= order_date)
);

CREATE TABLE order_items (
    row_id         INTEGER       PRIMARY KEY,
    order_id       VARCHAR(20)   NOT NULL REFERENCES orders (order_id),
    product_key    INTEGER       NOT NULL REFERENCES products (product_key),
    sales          NUMERIC(12,4) NOT NULL CHECK (sales > 0),
    quantity       INTEGER       NOT NULL CHECK (quantity > 0),
    discount       NUMERIC(4,2)  NOT NULL CHECK (discount BETWEEN 0 AND 1),
    profit         NUMERIC(12,4) NOT NULL,
    cost           NUMERIC(12,4) NOT NULL
);

COMMENT ON COLUMN order_items.cost IS 'DERIVED in Python: sales - profit. Not source data.';

CREATE INDEX idx_orders_customer   ON orders (customer_id);
CREATE INDEX idx_orders_date       ON orders (order_date);
CREATE INDEX idx_items_order       ON order_items (order_id);
CREATE INDEX idx_items_product     ON order_items (product_key);