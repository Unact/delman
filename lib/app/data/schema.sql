CREATE TABLE deliveries(
    id INTEGER UNIQUE,
    active INTEGER,

    localTs DATETIME DEFAULT CURRENT_TIMESTAMP,
    localId INTEGER PRIMARY KEY
);
CREATE TABLE deliveryPoints(
    id INTEGER UNIQUE,
    deliveryId INTEGER,

    seq NUMERIC,
    planArrival DATETIME,
    planDeparture DATETIME,
    factArrival DATETIME,
    factDeparture DATETIME,
    addressName TEXT,
    latitude NUMERIC,
    longitude NUMERIC,
    phone TEXT,
    paymentTypeName TEXT,
    buyerName TEXT,
    sellerName TEXT,
    deliveryTypeName TEXT,

    localTs DATETIME DEFAULT CURRENT_TIMESTAMP,
    localId INTEGER PRIMARY KEY
);
CREATE TABLE orders(
    id INTEGER UNIQUE,
    deliveryPointId INTEGER,
    deliveryPointOrderId INTEGER,

    deliveryFrom DATETIME,
    deliveryTo DATETIME,
    number TEXT,
    trackingNumber TEXT,
    buyerName TEXT,
    phone TEXT,
    comment TEXT,
    deliveryTypeName TEXT,
    floor INTEGER,
    flat TEXT,
    elevator INTEGER,
    paymentTypeName TEXT,
    sellerName TEXT,
    canceled INTEGER,
    finished INTEGER,

    localTs DATETIME DEFAULT CURRENT_TIMESTAMP,
    localId INTEGER PRIMARY KEY
);
CREATE TABLE orderLines(
    id INTEGER UNIQUE,
    orderId INTEGER,

    name TEXT,
    amount INTEGER,
    price NUMERIC,
    factAmount NUMERIC,

    localTs DATETIME DEFAULT CURRENT_TIMESTAMP,
    localId INTEGER PRIMARY KEY
);
CREATE TABLE payments(
    id INTEGER UNIQUE,
    deliveryPointOrderId INTEGER,

    summ NUMERIC,
    transactionId TEXT,

    localTs DATETIME DEFAULT CURRENT_TIMESTAMP,
    localId INTEGER PRIMARY KEY
);
