import type { PublicBoardMemberRow, PublicClubRow } from './public-clubs.types';

const day = (d: Date | null): string | null => (d ? d.toISOString().slice(0, 10) : null);

export function publicClubSummaryDto(row: PublicClubRow) {
  return {
    id: row.id,
    name: row.name,
    shortName: row.shortName,
    slug: row.slug,
    zoneId: row.zoneId,
    lat: row.lat,
    lng: row.lng,
    president: row.president,
    phone: row.phone,
    email: row.email,
    rotaryId: null,
    secretary: row.secretary,
    secretaryEmail: null,
    secretaryPhone: null,
    meetingInfo: row.meetingInfo,
    charterDate: day(row.charterDate),
    logoUrl: row.logoUrl,
    memberCount: row.memberCount,
  };
}

export function publicClubDetailDto(row: PublicClubRow) {
  // Keep contact PII redacted to match the summary; anonymous callers never get officer email/phone.
  return {
    ...publicClubSummaryDto(row),
    secretary: row.secretary,
    meetingInfo: row.meetingInfo,
    socialLinks: row.socialLinks ?? null,
    charterDate: day(row.charterDate),
  };
}

export function publicBoardMemberDto(row: PublicBoardMemberRow) {
  return {
    id: row.id,
    name: row.name,
    position: row.position,
    ryYear: row.ryYear,
  };
}
