-- Auto-generated PostgreSQL schema

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE "app_settings" (
    "id" SERIAL,
    "business_name" VARCHAR(255),
    "website_url" VARCHAR(255),
    "support_email" VARCHAR(255),
    "contact_whatsapp" VARCHAR(50),
    "company_logo_url" VARCHAR(500),
    "modempay_api_key" VARCHAR(255),
    "modempay_public_key" VARCHAR(255),
    "payment_return_url" VARCHAR(500),
    "payment_cancel_url" VARCHAR(500),
    "payments_enabled" BOOLEAN,
    "cloudinary_cloud_name" VARCHAR(255),
    "cloudinary_api_key" VARCHAR(255),
    "cloudinary_api_secret" VARCHAR(255),
    "whatsapp_access_token" VARCHAR(500),
    "whatsapp_phone_number_id" VARCHAR(100),
    "whatsapp_business_name" VARCHAR(255),
    "whatsapp_bulk_messaging_enabled" BOOLEAN,
    "smtp_server" VARCHAR(255),
    "smtp_port" INTEGER,
    "smtp_use_tls" BOOLEAN,
    "smtp_username" VARCHAR(255),
    "smtp_password" VARCHAR(255),
    "ai_api_key" VARCHAR(255),
    "ai_auto_prompt_improvements" BOOLEAN,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "backup_enabled" BOOLEAN DEFAULT FALSE,
    "backup_time" VARCHAR(8) DEFAULT '02:00',
    "backup_email" VARCHAR(255),
    "backup_retention_days" INTEGER DEFAULT 30,
    "backup_last_run" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "backup_last_status" VARCHAR(20),
    "backup_last_message" TEXT
);

CREATE TABLE "cart_item" (
    "id" SERIAL,
    "user_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    FOREIGN KEY ("product_id") REFERENCES "product" ("id"),
    FOREIGN KEY ("user_id") REFERENCES "user" ("id")
);

CREATE TABLE "category" (
    "id" SERIAL,
    "name" VARCHAR(50) NOT NULL,
    "image" VARCHAR(200),
    UNIQUE ("name")
);

CREATE TABLE "customer_feedback" (
    "id" SERIAL,
    "user_id" INTEGER NOT NULL,
    "order_id" INTEGER NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "image_path" VARCHAR(255),
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "is_published" BOOLEAN,
    FOREIGN KEY ("order_id") REFERENCES "order" ("id"),
    FOREIGN KEY ("user_id") REFERENCES "user" ("id")
);

CREATE TABLE "database_backup_log" (
    "id" SERIAL,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    "status" VARCHAR(20) NOT NULL,
    "file_paths" TEXT,
    "error_message" TEXT,
    "trigger" VARCHAR(20),
    "email_recipient" VARCHAR(255)
);

CREATE TABLE "database_log" (
    "id" SERIAL,
    "user_id" INTEGER NOT NULL,
    "action" VARCHAR(50) NOT NULL,
    "table_name" VARCHAR(100),
    "row_id" VARCHAR(100),
    "details" TEXT,
    "timestamp" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    FOREIGN KEY ("user_id") REFERENCES "user" ("id")
);

CREATE TABLE "email_campaign" (
    "id" SERIAL,
    "subject" VARCHAR(200) NOT NULL,
    "content" TEXT NOT NULL,
    "audience" VARCHAR(50),
    "status" VARCHAR(20),
    "scheduled_for" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "sent_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "created_by" INTEGER,
    FOREIGN KEY ("created_by") REFERENCES "user" ("id")
);

CREATE TABLE "email_log" (
    "id" SERIAL,
    "email_type" VARCHAR(50),
    "recipient" VARCHAR(120) NOT NULL,
    "subject" VARCHAR(200),
    "sent_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "status" VARCHAR(20),
    "campaign_id" INTEGER,
    "order_id" INTEGER,
    "error_message" TEXT,
    FOREIGN KEY ("order_id") REFERENCES "order" ("id"),
    FOREIGN KEY ("campaign_id") REFERENCES "email_campaign" ("id")
);

CREATE TABLE "newsletter_subscriber" (
    "id" SERIAL,
    "email" VARCHAR(120) NOT NULL,
    "name" VARCHAR(100),
    "is_active" BOOLEAN,
    "subscribed_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "last_sent" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE ("email")
);

CREATE TABLE "order" (
    "id" SERIAL,
    "user_id" INTEGER NOT NULL,
    "total" DOUBLE PRECISION NOT NULL,
    "status" VARCHAR(20),
    "payment_method" VARCHAR(50),
    "delivery_address" TEXT NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "shipping_status" VARCHAR(20) DEFAULT 'pending',
    "assigned_to" INTEGER,
    "weight_kg" DOUBLE PRECISION,
    "shipping_price" DOUBLE PRECISION,
    "total_cost" DOUBLE PRECISION,
    "customer_name" VARCHAR(255),
    "customer_address" TEXT,
    "customer_phone" VARCHAR(50),
    "location" VARCHAR(50),
    "shipped_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "delivered_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "product_weight_kg" DOUBLE PRECISION,
    "shipping_price_gmd" DOUBLE PRECISION,
    "total_cost_gmd" DOUBLE PRECISION,
    "details_submitted" BOOLEAN DEFAULT FALSE,
    "submitted_by" INTEGER,
    "submitted_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    FOREIGN KEY ("user_id") REFERENCES "user" ("id")
);

CREATE TABLE "order_item" (
    "id" SERIAL,
    "order_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL,
    "price" DOUBLE PRECISION NOT NULL,
    FOREIGN KEY ("product_id") REFERENCES "product" ("id"),
    FOREIGN KEY ("order_id") REFERENCES "order" ("id")
);

CREATE TABLE "payment_methods" (
    "id" SERIAL,
    "name" VARCHAR(50) NOT NULL,
    "display_name" VARCHAR(100) NOT NULL,
    "is_active" BOOLEAN,
    "is_enabled" BOOLEAN,
    "min_amount" DOUBLE PRECISION,
    "max_amount" DOUBLE PRECISION,
    "fee_percentage" DOUBLE PRECISION,
    "fee_fixed" DOUBLE PRECISION,
    "config" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE ("name")
);

CREATE TABLE "payment_transactions" (
    "id" SERIAL,
    "payment_id" INTEGER NOT NULL,
    "action" VARCHAR(50) NOT NULL,
    "status" VARCHAR(20) NOT NULL,
    "request_data" TEXT,
    "response_data" TEXT,
    "error_message" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    FOREIGN KEY ("payment_id") REFERENCES "payments" ("id")
);

CREATE TABLE "payments" (
    "id" SERIAL,
    "order_id" INTEGER NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "method" VARCHAR(50) NOT NULL,
    "reference" VARCHAR(100) NOT NULL,
    "status" VARCHAR(20),
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "paid_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "transaction_id" VARCHAR(100),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "payment_provider_response" TEXT,
    "failure_reason" VARCHAR(255),
    FOREIGN KEY ("order_id") REFERENCES "order" ("id")
);

CREATE TABLE "product" (
    "id" SERIAL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT NOT NULL,
    "price" DOUBLE PRECISION NOT NULL,
    "stock" INTEGER NOT NULL,
    "image" VARCHAR(200),
    "category_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "available_in_gambia" BOOLEAN NOT NULL DEFAULT FALSE,
    "delivery_price" DOUBLE PRECISION,
    "location" VARCHAR(50),
    FOREIGN KEY ("category_id") REFERENCES "category" ("id")
);

CREATE TABLE "product_restock_request" (
    "id" SERIAL,
    "product_id" INTEGER NOT NULL,
    "email" VARCHAR(120) NOT NULL,
    "is_notified" BOOLEAN,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "notified_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    FOREIGN KEY ("product_id") REFERENCES "product" ("id")
);

CREATE TABLE "shipment_record" (
    "id" SERIAL,
    "weight_total" DOUBLE PRECISION NOT NULL,
    "shipping_price" DOUBLE PRECISION NOT NULL,
    "total_cost" DOUBLE PRECISION NOT NULL,
    "submitted_by" INTEGER NOT NULL,
    "submission_date" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    "order_ids" TEXT NOT NULL,
    "verified" BOOLEAN NOT NULL DEFAULT FALSE,
    "verified_by" INTEGER,
    "verified_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    FOREIGN KEY ("submitted_by") REFERENCES "user" ("id")
);

CREATE TABLE "site_setting" (
    "id" SERIAL,
    "logo_path" VARCHAR(255),
    "hero_title" VARCHAR(255),
    "hero_subtitle" VARCHAR(255),
    "hero_image_path" VARCHAR(255)
);

CREATE TABLE "site_settings" (
    "id" SERIAL,
    "logo_path" VARCHAR(255),
    "hero_title" VARCHAR(200),
    "hero_subtitle" VARCHAR(255),
    "hero_button_text" VARCHAR(100),
    "hero_button_link" VARCHAR(255),
    "hero_icon" VARCHAR(50),
    "hero_image_path" VARCHAR(255)
);

CREATE TABLE "subscriber" (
    "id" SERIAL,
    "email" VARCHAR(120) NOT NULL,
    "whatsapp_number" VARCHAR(32) NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE "user" (
    "id" SERIAL,
    "username" VARCHAR(80) NOT NULL,
    "email" VARCHAR(120) NOT NULL,
    "password_hash" VARCHAR(128),
    "is_admin" BOOLEAN,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "google_id" VARCHAR(255),
    "password_updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "last_login_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "role" VARCHAR(50) DEFAULT 'customer',
    "active" BOOLEAN NOT NULL DEFAULT TRUE,
    "whatsapp_number" VARCHAR(32),
    UNIQUE ("email"),
    UNIQUE ("username")
);

CREATE TABLE "user_payment_method" (
    "id" SERIAL,
    "user_id" INTEGER NOT NULL,
    "provider" VARCHAR(80) NOT NULL,
    "label" VARCHAR(120),
    "account_identifier" VARCHAR(120) NOT NULL,
    "account_last4" VARCHAR(4),
    "is_default" BOOLEAN,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    FOREIGN KEY ("user_id") REFERENCES "user" ("id")
);

CREATE TABLE "user_profile" (
    "id" SERIAL,
    "user_id" INTEGER NOT NULL,
    "first_name" VARCHAR(120),
    "last_name" VARCHAR(120),
    "phone_number" VARCHAR(32),
    "address" VARCHAR(255),
    "city" VARCHAR(120),
    "state" VARCHAR(120),
    "postal_code" VARCHAR(20),
    "country" VARCHAR(120),
    "avatar_filename" VARCHAR(255),
    "avatar_updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "google_avatar_url" VARCHAR(512),
    "google_avatar_synced_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "notify_email" BOOLEAN,
    "notify_sms" BOOLEAN,
    "notify_push" BOOLEAN,
    "marketing_opt_in" BOOLEAN,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    FOREIGN KEY ("user_id") REFERENCES "user" ("id"),
    UNIQUE ("user_id")
);

CREATE TABLE "whats_app_message_log" (
    "id" SERIAL,
    "user_id" INTEGER,
    "subscriber_id" INTEGER,
    "whatsapp_number" VARCHAR(32) NOT NULL,
    "message" TEXT NOT NULL,
    "status" VARCHAR(20),
    "error_message" TEXT,
    "message_id" VARCHAR(100),
    "timestamp" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    FOREIGN KEY ("subscriber_id") REFERENCES "subscriber" ("id"),
    FOREIGN KEY ("user_id") REFERENCES "user" ("id")
);

CREATE TABLE "whatsapp_message_log" (
    "id" SERIAL,
    "user_id" INTEGER,
    "subscriber_id" INTEGER,
    "whatsapp_number" VARCHAR(32) NOT NULL,
    "message" TEXT NOT NULL,
    "status" VARCHAR(20) DEFAULT 'pending',
    "error_message" TEXT,
    "message_id" VARCHAR(100),
    "timestamp" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    FOREIGN KEY ("subscriber_id") REFERENCES "subscriber" ("id"),
    FOREIGN KEY ("user_id") REFERENCES "user" ("id")
);

CREATE TABLE "wishlist_item" (
    "id" SERIAL,
    "user_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    FOREIGN KEY ("product_id") REFERENCES "product" ("id"),
    FOREIGN KEY ("user_id") REFERENCES "user" ("id")
);
