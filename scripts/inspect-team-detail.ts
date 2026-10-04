import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL,
    },
  },
});

async function inspectTeam() {
  const members = await prisma.districtTeamMember.findMany();
  console.log(`TOTAL MEMBERS IN district_team: ${members.length}`);
  members.forEach(m => {
    console.log(`- [${m.id}] ${m.name} (${m.designation}) | ryYear: ${m.ryYear} | photoUrl: ${m.photoUrl}`);
  });
  await prisma.$disconnect();
}

inspectTeam();
