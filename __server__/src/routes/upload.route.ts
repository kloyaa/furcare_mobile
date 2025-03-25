import { Router } from 'express';
import { isAuthenticated } from '../_core/middlewares/jwt.middleware';
import { uploadImages } from '../controllers/upload.controller';

const router = Router();

const commonMiddlewares = [isAuthenticated];

router.post('/upload/v1', commonMiddlewares, uploadImages as any);

export default router;
