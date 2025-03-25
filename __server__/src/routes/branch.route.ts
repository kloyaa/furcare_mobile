import { Router } from 'express';
import { isAuthenticated } from '../_core/middlewares/jwt.middleware';
import { getBranches } from '../controllers/branch.controller';
const router = Router();

const commonMiddlewares = [
    isAuthenticated
];

router.get('/branch/v1', commonMiddlewares, getBranches as any);

export default router;