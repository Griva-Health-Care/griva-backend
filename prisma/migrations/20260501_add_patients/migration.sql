CREATE TABLE node_app."Patient" (
  "id"          TEXT NOT NULL DEFAULT gen_random_uuid(),
  "uuid"        TEXT NOT NULL,
  "patientName" TEXT NOT NULL,
  "userId"      TEXT NOT NULL,
  "hasReport"   BOOLEAN NOT NULL DEFAULT false,
  "createdAt"   TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt"   TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "Patient_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "Patient_userId_fkey" FOREIGN KEY ("userId")
    REFERENCES node_app."User"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE UNIQUE INDEX "Patient_uuid_key" ON node_app."Patient"("uuid");
CREATE INDEX "Patient_userId_idx"      ON node_app."Patient"("userId");
