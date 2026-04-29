CREATE TABLE IF NOT EXISTS node_app."Notification" (
    "id"        TEXT         NOT NULL,
    "userId"    TEXT         NOT NULL,
    "title"     TEXT         NOT NULL,
    "body"      TEXT         NOT NULL,
    "caseId"    TEXT,
    "isRead"    BOOLEAN      NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Notification_pkey" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "Notification_userId_isRead_idx" ON node_app."Notification"("userId", "isRead");
CREATE INDEX IF NOT EXISTS "Notification_createdAt_idx"     ON node_app."Notification"("createdAt");
