import { Router } from 'express';
import { prisma } from '../utils/prisma';
import { authMiddleware } from '../middleware/auth.middleware';
import { requireRole } from '../middleware/role.middleware';

const router = Router();

const adminOnly = [
  authMiddleware,
  requireRole('admin', 'superadmin'),
];

// GET /admin/users
router.get('/users', ...adminOnly, async (req, res) => {
  try {
    const role =
      typeof req.query.role === 'string'
        ? req.query.role
        : undefined;

    const isActive =
      typeof req.query.isActive === 'string'
        ? req.query.isActive
        : undefined;

    const users = await prisma.user.findMany({
      where: {
        ...(role ? { role } : {}),
        ...(isActive !== undefined
          ? { isActive: isActive === 'true' }
          : {}),
      },
      select: {
        id: true,
        email: true,
        fullName: true,
        role: true,
        hospital: true,
        phone: true,
        city: true,
        state: true,
        licenseNumber: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return res.json({ users });
  } catch (error) {
    console.error(
      '[ADMIN USERS]',
      error instanceof Error ? error.stack : error
    );

    return res.status(500).json({
      message: 'Failed to list users',
    });
  }
});

// PUT /admin/users/:id/role
router.put('/users/:id/role', ...adminOnly, async (req, res) => {
  try {
    const id = req.params['id'] as string;

    const { role } = req.body as {
      role: string;
    };

    const validRoles = [
      'doctor',
      'diagnostic',
      'tele_reporter',
      'admin',
      'superadmin',
    ];

    if (!validRoles.includes(role)) {
      return res.status(400).json({
        message: `Invalid role. Must be one of: ${validRoles.join(', ')}`,
      });
    }

    const user = await prisma.user.update({
      where: { id },
      data: { role },
      select: {
        id: true,
        email: true,
        role: true,
        isActive: true,
      },
    });

    return res.json({ user });
  } catch (error) {
    console.error(
      '[ADMIN ROLE UPDATE]',
      error instanceof Error ? error.stack : error
    );

    return res.status(500).json({
      message: 'Failed to update role',
    });
  }
});

// PUT /admin/users/:id/status
router.put('/users/:id/status', ...adminOnly, async (req, res) => {
  try {
    const id = req.params['id'] as string;

    const { isActive } = req.body as {
      isActive: boolean;
    };

    if (typeof isActive !== 'boolean') {
      return res.status(400).json({
        message: 'isActive must be a boolean',
      });
    }

    const user = await prisma.user.update({
      where: { id },
      data: { isActive },
      select: {
        id: true,
        email: true,
        role: true,
        isActive: true,
      },
    });

    return res.json({ user });
  } catch (error) {
    console.error(
      '[ADMIN STATUS UPDATE]',
      error instanceof Error ? error.stack : error
    );

    return res.status(500).json({
      message: 'Failed to update user status',
    });
  }
});

// GET /admin/overview
router.get('/overview', ...adminOnly, async (_req, res) => {
  try {
    const users = await prisma.user.findMany({
      where: {
        role: {
          in: ['doctor', 'diagnostic'],
        },
      },
      select: {
        id: true,
        fullName: true,
        email: true,
        role: true,
        hospital: true,
        phone: true,
        city: true,
        state: true,
        licenseNumber: true,
        createdAt: true,
        patients: {
          select: {
            hasReport: true,
          },
        },
      },
      orderBy: {
        createdAt: 'asc',
      },
    });

    const diagnosticIds = users
      .filter((u) => u.role === 'diagnostic')
      .map((u) => u.id);

    const teleCaseCounts = diagnosticIds.length
      ? await prisma.teleCase.groupBy({
          by: ['submittedBy'],
          where: {
            submittedBy: {
              in: diagnosticIds,
            },
            status: 'completed',
          },
          _count: {
            id: true,
          },
        })
      : [];

    const teleCountMap = new Map(
      teleCaseCounts.map((row) => [
        row.submittedBy,
        row._count.id,
      ])
    );

    const rows = users.map((u) => {
      const patientCount = u.patients.length;

      const reportCount =
        u.role === 'diagnostic'
          ? (teleCountMap.get(u.id) ?? 0)
          : u.patients.filter((p) => p.hasReport).length;

      return {
        id: u.id,
        name: u.fullName ?? u.email,
        email: u.email,
        role: u.role,
        accountType: u.role,
        hospital: u.hospital ?? null,
        phone: u.phone ?? null,
        city: u.city ?? null,
        state: u.state ?? null,
        licenseNumber: u.licenseNumber ?? null,
        patientCount,
        reportCount,
        joinedAt: u.createdAt,
      };
    });

    return res.json({
      users: rows,
    });
  } catch (error) {
    console.error(
      '[ADMIN OVERVIEW FULL]',
      error instanceof Error ? error.stack : error
    );

    return res.status(500).json({
      message: 'Failed to fetch overview',
    });
  }
});

export default router;
