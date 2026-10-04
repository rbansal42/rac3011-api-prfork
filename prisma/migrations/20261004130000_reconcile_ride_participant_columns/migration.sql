-- Reconcile ride_participants and ride_gallery_items with prisma/schema. These columns and the
-- enum->text conversions were applied to the live DB by hand (scripts/align_ride_schema.sql), which
-- `prisma migrate deploy` never runs, so a fresh database was missing them and every ride participant
-- or gallery query failed. Written idempotently so it is a no-op on the already-patched live DB.

-- ride_participants: columns the schema declares but no migration creates.
ALTER TABLE "ride_participants"
  ADD COLUMN IF NOT EXISTS "ry_year" INTEGER DEFAULT 2026,
  ADD COLUMN IF NOT EXISTS "edition" TEXT DEFAULT 'delhi_meri_jaan_2026',
  ADD COLUMN IF NOT EXISTS "rotary_id" TEXT,
  ADD COLUMN IF NOT EXISTS "home_district" TEXT,
  ADD COLUMN IF NOT EXISTS "home_club_name" TEXT,
  ADD COLUMN IF NOT EXISTS "city_state" TEXT,
  ADD COLUMN IF NOT EXISTS "country" TEXT DEFAULT 'India',
  ADD COLUMN IF NOT EXISTS "club_designation" TEXT,
  ADD COLUMN IF NOT EXISTS "dietary_pref" TEXT DEFAULT 'veg',
  ADD COLUMN IF NOT EXISTS "allergies_notes" TEXT,
  ADD COLUMN IF NOT EXISTS "emergency_name" TEXT,
  ADD COLUMN IF NOT EXISTS "emergency_phone" TEXT,
  ADD COLUMN IF NOT EXISTS "emergency_relation" TEXT,
  ADD COLUMN IF NOT EXISTS "arrival_at" TIMESTAMP(3),
  ADD COLUMN IF NOT EXISTS "arrival_number" TEXT,
  ADD COLUMN IF NOT EXISTS "departure_at" TIMESTAMP(3),
  ADD COLUMN IF NOT EXISTS "host_club_id" TEXT,
  ADD COLUMN IF NOT EXISTS "host_family_name" TEXT,
  ADD COLUMN IF NOT EXISTS "host_family_phone" TEXT,
  ADD COLUMN IF NOT EXISTS "host_address" TEXT,
  ADD COLUMN IF NOT EXISTS "payment_status" TEXT DEFAULT 'pending',
  ADD COLUMN IF NOT EXISTS "payment_ref" TEXT;

-- status / participant_type are enum-typed in the chain but String in the schema.
ALTER TABLE "ride_participants" ALTER COLUMN "status" DROP DEFAULT;
ALTER TABLE "ride_participants" ALTER COLUMN "status" TYPE TEXT USING "status"::text;
ALTER TABLE "ride_participants" ALTER COLUMN "status" SET DEFAULT 'submitted';
ALTER TABLE "ride_participants" ALTER COLUMN "participant_type" DROP DEFAULT;
ALTER TABLE "ride_participants" ALTER COLUMN "participant_type" TYPE TEXT USING "participant_type"::text;
ALTER TABLE "ride_participants" ALTER COLUMN "participant_type" SET DEFAULT 'external';

-- ride_gallery_items heading columns.
ALTER TABLE "ride_gallery_items"
  ADD COLUMN IF NOT EXISTS "heading_left" TEXT,
  ADD COLUMN IF NOT EXISTS "heading_right" TEXT;

-- CreateIndex
CREATE INDEX IF NOT EXISTS "ride_participants_ry_year_status_idx" ON "ride_participants"("ry_year", "status");
CREATE INDEX IF NOT EXISTS "ride_participants_home_district_idx" ON "ride_participants"("home_district");
CREATE INDEX IF NOT EXISTS "ride_participants_is_active_idx" ON "ride_participants"("is_active");
CREATE INDEX IF NOT EXISTS "ride_participants_approval_status_idx" ON "ride_participants"("approval_status");

-- AddForeignKey
DO $$ BEGIN
  ALTER TABLE "ride_participants" ADD CONSTRAINT "ride_participants_host_club_id_fkey" FOREIGN KEY ("host_club_id") REFERENCES "clubs"("id") ON DELETE SET NULL ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null; END $$;
