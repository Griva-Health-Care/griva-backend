/*
  Warnings:

  - You are about to drop the `DoctorConfig` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `DoctorProfile` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropTable
DROP TABLE "node_app"."DoctorConfig";

-- DropTable
DROP TABLE "node_app"."DoctorProfile";

-- CreateTable
CREATE TABLE "doctor_profiles" (
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

    CONSTRAINT "doctor_profiles_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "doctor_config" (
    "uid" TEXT NOT NULL,
    "cloudSyncEnabled" BOOLEAN NOT NULL DEFAULT false,
    "role" TEXT NOT NULL DEFAULT 'solo',
    "creditBalance" INTEGER NOT NULL DEFAULT 0,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "doctor_config_pkey" PRIMARY KEY ("uid")
);
