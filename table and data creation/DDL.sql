CREATE SCHEMA IF NOT EXISTS product_analytics;
SET search_path TO product_analytics;
-- Marketing Campaign Table
CREATE TABLE IF NOT EXISTS marketing_campaign (
    campaign_name VARCHAR(100) PRIMARY KEY,
    spend DECIMAL(10, 2),
    launch_date DATE,
    end_date DATE
);

-- Ads Exposure Table
CREATE TABLE IF NOT EXISTS ads_exposure (
    id SERIAL PRIMARY KEY,
    campaign_name VARCHAR(100),
    is_clicked BOOLEAN,
    timestamp timestamp,
    duration INT,  -- in seconds
    email VARCHAR(100),
    FOREIGN KEY (campaign_name) REFERENCES marketing_campaign(campaign_name)
);

-- Website Event Table
CREATE TABLE IF NOT EXISTS website_event (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    event_name VARCHAR(100) NOT NULL,
    path VARCHAR(255) NOT NULL,
    timestamp timestamp NOT NULL
);

-- Purchase Table
CREATE TABLE IF NOT EXISTS purchase (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    plan VARCHAR(50) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    timestamp timestamp NOT NULL
);

-- Subscription Table
CREATE TABLE IF NOT EXISTS subscription (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    purchase_id INT,
    FOREIGN KEY (purchase_id) REFERENCES purchase(id)
);

-- Registration Table
CREATE TABLE IF NOT EXISTS registration (
	id SERIAL PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    timestamp timestamp NOT NULL
);

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_website_event_user_id ON website_event (user_id);
CREATE INDEX IF NOT EXISTS idx_website_event_timestamp ON website_event (timestamp);

CREATE INDEX IF NOT EXISTS idx_purchase_user_id ON purchase (user_id);
CREATE INDEX IF NOT EXISTS idx_purchase_timestamp ON purchase (timestamp);

CREATE INDEX IF NOT EXISTS idx_registration_user_id ON registration (user_id);
CREATE INDEX IF NOT EXISTS idx_registration_email ON registration (email);
CREATE INDEX IF NOT EXISTS idx_registration_timestamp ON registration (timestamp);

CREATE INDEX IF NOT EXISTS idx_subscription_user_id ON subscription (user_id);
CREATE INDEX IF NOT EXISTS idx_subscription_start_date ON subscription (start_date);
CREATE INDEX IF NOT EXISTS idx_subscription_end_date ON subscription (end_date);