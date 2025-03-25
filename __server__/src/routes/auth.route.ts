import { Router } from 'express';
import { changeUserPassword, ekyc, login, register } from '../controllers/auth.controller';
import { isAuthenticated } from '../_core/middlewares/jwt.middleware';
import { isAdmin } from '../_core/middlewares/is_admin.middleware';
import { isProfileCreated } from '../_core/middlewares/is_profile_created.middleware';
const router = Router();

const commonMiddlewares = [
    isAuthenticated,
];

router.post('/auth/v1/login', login as any);
router.post('/auth/v1/register', register as any);
router.post('/auth/v1/change-password', commonMiddlewares, changeUserPassword as any);
router.post('/auth/v1/ekyc', [...commonMiddlewares, isAdmin], ekyc as any);

export default router;
