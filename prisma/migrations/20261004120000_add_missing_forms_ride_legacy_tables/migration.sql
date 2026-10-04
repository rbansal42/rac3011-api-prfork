-- Reconcile the migration chain with prisma/schema: these enums and tables exist
-- in the Prisma schema but were never captured by a migration, so `prisma migrate
-- deploy` on a fresh database produced a schema the application code queries but
-- that does not exist. Written idempotently (guards + IF NOT EXISTS) so it also
-- applies cleanly on the live database, where these objects were created by hand.

-- CreateEnum
DO $$ BEGIN
  CREATE TYPE "FormStatus" AS ENUM ('draft', 'published', 'archived');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
  CREATE TYPE "FormAccessMode" AS ENUM ('all', 'specific', 'none');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
  CREATE TYPE "FormSubmissionStatus" AS ENUM ('submitted', 'under_review', 'approved', 'declined');
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- CreateTable
CREATE TABLE IF NOT EXISTS "custom_forms" (
    "id" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "category" TEXT DEFAULT 'General',
    "status" "FormStatus" NOT NULL DEFAULT 'draft',
    "access_mode" "FormAccessMode" NOT NULL DEFAULT 'all',
    "target_surface" TEXT NOT NULL DEFAULT 'dashboard',
    "target_roles" JSONB,
    "target_club_ids" JSONB,
    "fields" JSONB NOT NULL,
    "is_public" BOOLEAN NOT NULL DEFAULT false,
    "created_by_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "custom_forms_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "custom_form_submissions" (
    "id" TEXT NOT NULL,
    "form_id" TEXT NOT NULL,
    "user_id" TEXT,
    "applicant_name" TEXT,
    "applicant_email" TEXT,
    "applicant_phone" TEXT,
    "club_id" TEXT,
    "club_name" TEXT,
    "status" "FormSubmissionStatus" NOT NULL DEFAULT 'submitted',
    "values" JSONB NOT NULL,
    "notes" TEXT,
    "reviewed_by_id" TEXT,
    "reviewed_at" TIMESTAMP(3),
    "submitted_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "custom_form_submissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "ride_resources" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "category" TEXT NOT NULL DEFAULT 'guidelines',
    "scope" TEXT NOT NULL DEFAULT 'all',
    "target_club_name" TEXT,
    "target_member_email" TEXT,
    "target_district" TEXT,
    "drive_url" TEXT NOT NULL,
    "description" TEXT,
    "order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ride_resources_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "ride_announcements" (
    "id" TEXT NOT NULL,
    "subject" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "sender" TEXT NOT NULL DEFAULT 'RIDE Organizing Committee (RID 3011)',
    "audience_scope" TEXT NOT NULL DEFAULT 'all',
    "target_districts" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "target_emails" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "host_clubs_only" BOOLEAN NOT NULL DEFAULT false,
    "recipient_count" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ride_announcements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "legacy_user_profiles" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "rotary_id" TEXT,
    "full_name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "role" TEXT NOT NULL DEFAULT 'president',
    "post" TEXT DEFAULT 'Club President',
    "club_name" TEXT DEFAULT 'District 3011',
    "phone" TEXT,
    "totp_secret" TEXT,
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "reset_token" TEXT,
    "reset_token_expires_at" TIMESTAMPTZ(6),
    "is_test_group" BOOLEAN DEFAULT false,

    CONSTRAINT "legacy_user_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "legacy_monthly_reports" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "month" TEXT NOT NULL,
    "club_name" TEXT NOT NULL,
    "club_email" TEXT NOT NULL,
    "submitted_by" TEXT NOT NULL,
    "status" TEXT DEFAULT 'reported',
    "flag_comment" TEXT,
    "sections_json" JSONB NOT NULL,
    "submitted_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "flag_reason" TEXT,
    "flagged_by" TEXT,
    "flagged_at" TIMESTAMPTZ(6),
    "section_flags" JSONB DEFAULT '{}',

    CONSTRAINT "legacy_monthly_reports_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "legacy_project_submissions" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "club_id" UUID,
    "club_name" TEXT NOT NULL,
    "club_email" TEXT,
    "submitted_by" TEXT,
    "title" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "description" TEXT,
    "budget" TEXT,
    "beneficiaries" TEXT,
    "proof_url" TEXT,
    "status" TEXT DEFAULT 'reported',
    "flag_comment" TEXT,
    "submitted_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "legacy_project_submissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "legacy_announcements" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "title" TEXT NOT NULL,
    "category" TEXT,
    "content" TEXT NOT NULL,
    "author_name" TEXT DEFAULT 'District Secretariat',
    "sent_via_email" BOOLEAN DEFAULT false,
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "target_audience" TEXT DEFAULT 'all',

    CONSTRAINT "legacy_announcements_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "custom_forms_slug_key" ON "custom_forms"("slug");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "custom_form_submissions_form_id_idx" ON "custom_form_submissions"("form_id");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "custom_form_submissions_user_id_idx" ON "custom_form_submissions"("user_id");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "custom_form_submissions_club_id_idx" ON "custom_form_submissions"("club_id");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "idx_user_profiles_role" ON "legacy_user_profiles"("role");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "idx_user_profiles_rotary_id" ON "legacy_user_profiles"("rotary_id");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "idx_monthly_reports_club_month" ON "legacy_monthly_reports"("club_email", "month");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "idx_monthly_reports_status" ON "legacy_monthly_reports"("status");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "idx_monthly_reports_submitted_at" ON "legacy_monthly_reports"("submitted_at" DESC);

-- CreateIndex
CREATE INDEX IF NOT EXISTS "idx_project_submissions_club_email" ON "legacy_project_submissions"("club_email");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "idx_project_submissions_submitted_at" ON "legacy_project_submissions"("submitted_at" DESC);

-- CreateIndex
CREATE INDEX IF NOT EXISTS "idx_announcements_audience" ON "legacy_announcements"("target_audience");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "idx_announcements_created_at" ON "legacy_announcements"("created_at" DESC);

-- AddForeignKey
DO $$ BEGIN
  ALTER TABLE "custom_form_submissions" ADD CONSTRAINT "custom_form_submissions_form_id_fkey" FOREIGN KEY ("form_id") REFERENCES "custom_forms"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null; END $$;
