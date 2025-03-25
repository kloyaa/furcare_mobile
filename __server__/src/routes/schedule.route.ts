import { Router } from 'express';
import { isAuthenticated } from '../_core/middlewares/jwt.middleware';
import { getSchedules } from '../controllers/schedules.controller';
const router = Router();

const commonMiddlewares = [
    isAuthenticated
];

router.get('/schedule/v1', commonMiddlewares, getSchedules as any);

export default router;