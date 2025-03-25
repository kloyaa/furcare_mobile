import { Router } from 'express';
import { createProfile, getProfileByAccessToken, updateProfileByAccessToken } from '../controllers/user.controller';
import { isAuthenticated } from '../_core/middlewares/jwt.middleware';

const router = Router();

const commonMiddlewares = [isAuthenticated];

router.post('/user/v1/profile/me', commonMiddlewares, createProfile as any);
router.get('/user/v1/profile/me', commonMiddlewares, getProfileByAccessToken as any);
router.put('/user/v1/profile/me', commonMiddlewares, updateProfileByAccessToken as any);

export default router;
