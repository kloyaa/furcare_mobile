import { Router } from 'express';
import { isAuthenticated } from '../_core/middlewares/jwt.middleware';
import { getCages  } from '../controllers/cage.controller';
const router = Router();

const commonMiddlewares = [
    isAuthenticated
];

router.get('/cage/v1', commonMiddlewares, getCages as any);

export default router;