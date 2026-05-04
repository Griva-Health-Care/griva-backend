/*
  Warnings:

  - You are about to drop the column `firebaseUid` on the `User` table. All the data in the column will be lost.
  - A unique constraint covering the columns `[supabaseUid]` on the table `User` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `supabaseUid` to the `User` table without a default value. This is not possible if the table is not empty.

*/
-- DropIndex
DROP INDEX "node_app"."User_firebaseUid_key";

-- AlterTable
ALTER TABLE "node_app"."Patient" ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "updatedAt" DROP DEFAULT;

-- AlterTable
ALTER TABLE "node_app"."User" DROP COLUMN "firebaseUid",
ADD COLUMN     "supabaseUid" TEXT NOT NULL;

-- CreateTable
CREATE TABLE "node_app"."DoctorProfile" (
    "uid" TEXT NOT NULL,
    "fullName" TEXT NOT NULL DEFAULT '',
    "phone" TEXT NOT NULL DEFAULT '',
    "hospital" TEXT NOT NULL DEFAULT '',
    "accountType" TEXT NOT NULL DEFAULT '',
    "licenseNumber" TEXT NOT NULL DEFAULT '',
    "city" TEXT NOT NULL DEFAULT '',
    "state" TEXT NOT NULL DEFAULT '',
    "colposcopeSerialNo" TEXT NOT NULL DEFAULT '',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "DoctorProfile_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "node_app"."DoctorConfig" (
    "uid" TEXT NOT NULL,
    "cloudSyncEnabled" BOOLEAN NOT NULL DEFAULT false,
    "role" TEXT NOT NULL DEFAULT 'solo',
    "creditBalance" INTEGER NOT NULL DEFAULT 0,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "DoctorConfig_pkey" PRIMARY KEY ("uid")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_supabaseUid_key" ON "node_app"."User"("supabaseUid");
