-- Sanitized placeholder data migration.
-- Regenerate this file with scripts/generate_postgres_artifacts.py
-- after seeding your own database. No sensitive information is stored here.

BEGIN;

-- Core application settings placeholder
INSERT INTO "app_settings" (
    "id", "business_name", "website_url", "support_email", "contact_whatsapp",
    "company_logo_url", "modempay_api_key", "modempay_public_key",
    "payment_return_url", "payment_cancel_url", "payments_enabled",
    "cloudinary_cloud_name", "cloudinary_api_key", "cloudinary_api_secret",
    "whatsapp_access_token", "whatsapp_phone_number_id", "whatsapp_business_name",
    "whatsapp_bulk_messaging_enabled", "smtp_server", "smtp_port", "smtp_use_tls",
    "smtp_username", "smtp_password", "ai_api_key", "ai_auto_prompt_improvements",
    "updated_at", "backup_enabled", "backup_time", "backup_email",
    "backup_retention_days", "backup_last_run", "backup_last_status", "backup_last_message"
) VALUES (
    1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, TRUE,
    NULL, NULL, NULL, 'YOUR_WHATSAPP_ACCESS_TOKEN', 'YOUR_WHATSAPP_PHONE_NUMBER_ID',
    'YOUR_WHATSAPP_BUSINESS_NAME', TRUE, 'smtp.gmail.com', 587, TRUE, NULL, NULL,
    NULL, FALSE, NOW(), TRUE, '02:00', 'admin@example.com', 30, NOW(), 'success', NULL
);

-- Minimal relational data to keep migrations valid
INSERT INTO "category" ("id", "name", "image")
VALUES (1, 'Sample Category', 'uploads/categories/sample.webp');

INSERT INTO "user" ("id", "username", "email", "password_hash", "is_admin", "created_at", "google_id", "role", "active")
VALUES (1, 'sample_user', 'customer@example.com', 'HASHED_PASSWORD_PLACEHOLDER', FALSE, NOW(), 'GOOGLE_USER_ID_PLACEHOLDER', 'customer', TRUE);

INSERT INTO "order" ("id", "user_id", "total", "status", "payment_method", "delivery_address", "created_at")
VALUES (1, 1, 10.0, 'pending', 'modempay', 'Sample Address', NOW());

COMMIT;

