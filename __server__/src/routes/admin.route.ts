import { Router } from 'express';
import { isAuthenticated } from '../_core/middlewares/jwt.middleware';
import { getCheckInStats, getCustomers, getSeriveUsageStats, getStaffs, removeUser, updateUserActiveStatus } from '../controllers/admin.controller';
import { getTransactions, updateProfileById } from '../controllers/booking.controller';
const router = Router();

const commonMiddlewares = [
    isAuthenticated
];

router.delete('/admin/v1/remove/user/:_id', removeUser as any);
router.get('/admin/v1/customers', getCustomers as any);
router.get('/admin/v1/staffs', getStaffs as any);
router.get('/admin/v1/stats/checkins', getCheckInStats as any);
router.get('/admin/v1/stats/service-usage', getSeriveUsageStats as any);
router.put('/admin/v1/management/user-status', updateUserActiveStatus as any);
router.get('/admin/v1/transactions', getTransactions as any);
router.put('/admin/v1/management/profile/:_id', updateProfileById as any);

export default router;
