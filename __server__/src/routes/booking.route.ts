import { Router } from 'express';
import { isAuthenticated } from '../_core/middlewares/jwt.middleware';
import { getBoardingApplicationsByAppId, getBookings, getBookingsByAccessToken, getGroomingApplicationsByAppId, getTransitApplicationsByAppId, updateBookingStatusById } from '../controllers/booking.controller';
import { isStaff } from '../_core/middlewares/is_staff.middleware';
import { isProfileCreated } from '../_core/middlewares/is_profile_created.middleware';
const router = Router();

const commonMiddlewares = [
    isAuthenticated,
    isStaff,
    isProfileCreated
];
router.get('/customer/v1/booking', [isAuthenticated, isProfileCreated], getBookingsByAccessToken as any);
router.get('/staff/v1/booking', commonMiddlewares, getBookings as any);
router.get('/staff/v1/booking/boarding/:_id', commonMiddlewares, getBoardingApplicationsByAppId as any);
router.get('/staff/v1/booking/grooming/:_id', commonMiddlewares, getGroomingApplicationsByAppId as any);
router.get('/staff/v1/booking/transit/:_id', commonMiddlewares, getTransitApplicationsByAppId as any);

router.put('/staff/v1/booking/status', commonMiddlewares, updateBookingStatusById as any);

export default router;