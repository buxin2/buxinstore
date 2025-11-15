## Vercel + Neon Deployment Guide

1. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

2. **Generate SQL artifacts (one-time)**
   ```bash
   python scripts/generate_postgres_artifacts.py
   ```
   Upload `schema_postgres.sql` to Neon (or `psql`) and run `data_migration.sql` afterwards.

3. **Configure environment variables**
   - Copy `env.template` to `.env` for local development.
   - In Vercel, add the same keys under *Project Settings → Environment Variables*.
   - Required keys: `DATABASE_URL`, `SECRET_KEY`, `GOOGLE_*`, `MAIL_*`, `MODEM_PAY_*`, `CLOUDINARY_*`, `WHATSAPP_*`.

4. **Local verification**
   ```bash
   python -m flask db upgrade  # optional if using migrations
   python run.py
   ```
   Ensure API endpoints, login, payments, and media uploads succeed against Neon.

5. **Deploy with Vercel CLI**
   ```bash
   npm i -g vercel
   vercel login
   vercel --prod
   ```
   Or push to GitHub and connect the repo to Vercel for automatic deployments.

6. **Post-deploy checks**
   - Confirm `/test` responds with HTTP 200.
   - Verify static assets (images, CSS, JS) load from `/static`.
   - Run smoke tests: login → checkout → ModemPay webhook → email/WhatsApp notifications.

