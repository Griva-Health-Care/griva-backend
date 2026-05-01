-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "node_app";

-- CreateTable
CREATE TABLE "node_app"."User" (
    "id"          TEXT        NOT NULL,
    "firebaseUid" TEXT        NOT NULL,
    "email"       TEXT        NOT NULL,
    "fullName"    TEXT,
    "role"        TEXT        NOT NULL DEFAULT 'doctor',
    "hospital"    TEXT,
    "isActive"    BOOLEAN     NOT NULL DEFAULT true,
    "isAvailable" BOOLEAN     NOT NULL DEFAULT true,
    "abhaNumber"  TEXT,
    "abhaAddress" TEXT,
    "hprId"       TEXT,
    "abdmLinked"  BOOLEAN     NOT NULL DEFAULT false,
    "createdAt"   TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt"   TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "node_app"."CreditTransaction" (
    "id"          TEXT        NOT NULL,
    "doctorUid"   TEXT        NOT NULL,
    "delta"       INTEGER     NOT NULL,
    "reason"      TEXT        NOT NULL,
    "adminUserId" TEXT,
    "caseUuid"    TEXT,
    "createdAt"   TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CreditTransaction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "node_app"."TeleCase" (
    "id"           TEXT        NOT NULL,
    "submittedBy"  TEXT        NOT NULL,
    "assignedUid"  TEXT,
    "assignedBy"   TEXT,
    "notes"        TEXT,
    "files"        JSONB       NOT NULL DEFAULT '[]',
    "status"       TEXT        NOT NULL DEFAULT 'pending',
    "reporterNote" TEXT,
    "completedAt"  TIMESTAMP(3),
    "createdAt"    TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt"    TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TeleCase_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "node_app"."AuditLog" (
    "id"        TEXT        NOT NULL,
    "userId"    TEXT,
    "action"    TEXT        NOT NULL,
    "details"   TEXT,
    "ipAddress" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "node_app"."AbdmSession" (
    "id"           TEXT        NOT NULL,
    "userId"       TEXT        NOT NULL,
    "accessToken"  TEXT        NOT NULL,
    "refreshToken" TEXT,
    "expiresAt"    TIMESTAMP(3) NOT NULL,
    "createdAt"    TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt"    TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AbdmSession_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_firebaseUid_key"  ON "node_app"."User"("firebaseUid");
CREATE UNIQUE INDEX "User_email_key"        ON "node_app"."User"("email");
CREATE UNIQUE INDEX "User_abhaNumber_key"   ON "node_app"."User"("abhaNumber");
CREATE UNIQUE INDEX "User_abhaAddress_key"  ON "node_app"."User"("abhaAddress");

CREATE INDEX "CreditTransaction_doctorUid_idx"  ON "node_app"."CreditTransaction"("doctorUid");
CREATE INDEX "CreditTransaction_createdAt_idx"  ON "node_app"."CreditTransaction"("createdAt");

CREATE INDEX "TeleCase_submittedBy_idx" ON "node_app"."TeleCase"("submittedBy");
CREATE INDEX "TeleCase_assignedUid_idx" ON "node_app"."TeleCase"("assignedUid");
CREATE INDEX "TeleCase_status_idx"      ON "node_app"."TeleCase"("status");
CREATE INDEX "TeleCase_createdAt_idx"   ON "node_app"."TeleCase"("createdAt");

CREATE INDEX "AuditLog_createdAt_idx" ON "node_app"."AuditLog"("createdAt");

CREATE UNIQUE INDEX "AbdmSession_userId_key" ON "node_app"."AbdmSession"("userId");

-- AddForeignKey
ALTER TABLE "node_app"."AbdmSession"
    ADD CONSTRAINT "AbdmSession_userId_fkey"
    FOREIGN KEY ("userId") REFERENCES "node_app"."User"("id")
    ON DELETE CASCADE ON UPDATE CASCADE;
