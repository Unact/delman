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
    sellerName TEXT,
    buyerName TEXT,
    phone TEXT,
    paymentTypeName TEXT,
    deliveryTypeName TEXT,

    pickupSellerName TEXT,
    senderName TEXT,
    senderPhone TEXT,

    localTs DATETIME DEFAULT CURRENT_TIMESTAMP,
    localId INTEGER PRIMARY KEY
);
CREATE TABLE orders(
    id INTEGER UNIQUE,
    orderId INTEGER,
    deliveryPointId INTEGER,

    pickup INTEGER,
    timeFrom DATETIME,
    timeTo DATETIME,
    number TEXT,
    trackingNumber TEXT,
    personName TEXT,
    phone TEXT,
    comment TEXT,
    deliveryTypeName TEXT,
    floor INTEGER,
    flat TEXT,
    elevator INTEGER,
    paymentTypeName TEXT,
    sellerName TEXT,
    documentsReturn INTEGER,
    canceled INTEGER,
    finished INTEGER,
    cardPaymentAllowed INTEGER,
    orderStorageId INTEGER,

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
CREATE TABLE orderStorages(
    id INTEGER UNIQUE,
    name TEXT,

    localTs DATETIME DEFAULT CURRENT_TIMESTAMP,
    localId INTEGER PRIMARY KEY
);
CREATE TABLE orderInfo(
    id INTEGER UNIQUE,
    orderId INTEGER,

    comment TEXT,
    ts DATETIME,

    localTs DATETIME DEFAULT CURRENT_TIMESTAMP,
    localId INTEGER PRIMARY KEY
);
