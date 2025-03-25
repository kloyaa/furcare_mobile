import { Router } from 'express';
import { isAuthenticated } from '../_core/middlewares/jwt.middleware';
import { getActivitiesByAccessToken } from '../controllers/activity.controller';
const router = Router();

const commonMiddlewares = [
    isAuthenticated
];

router.get('/activity/v1/me', commonMiddlewares, getActivitiesByAccessToken as any);

export default router;