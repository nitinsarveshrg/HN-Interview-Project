import { Router } from 'express';
import { z } from 'zod';
import { listProducts, getProduct, createProduct, updateProduct, deleteProduct, searchProducts } from '../../services/product.service.js';
const router = Router();
const productSchema = z.object({
    name: z.string().min(1),
    description: z.string().min(1),
    price: z.number().nonnegative(),
    category: z.string().min(1)
});
router.get('/', async (_req, res) => {
    const products = await listProducts();
    res.json(products);
});
router.post('/', async (req, res) => {
    const parse = productSchema.safeParse(req.body);
    if (!parse.success)
        return res.status(400).json({ error: parse.error.flatten() });
    const created = await createProduct(parse.data);
    res.status(201).json(created);
});
router.put('/:id', async (req, res) => {
    const id = req.params.id;
    const partialSchema = productSchema.partial();
    const parse = partialSchema.safeParse(req.body);
    if (!parse.success)
        return res.status(400).json({ error: parse.error.flatten() });
    const updated = await updateProduct(id, parse.data);
    if (!updated)
        return res.status(404).json({ error: 'Product not found' });
    res.json(updated);
});
router.delete('/:id', async (req, res) => {
    const ok = await deleteProduct(req.params.id);
    if (!ok)
        return res.status(404).json({ error: 'Product not found' });
    res.status(204).send();
});
router.get('/search', async (req, res) => {
    const q = req.query.query || '';
    const results = await searchProducts(q);
    res.json(results);
});
router.get('/:id', async (req, res) => {
    const product = await getProduct(req.params.id);
    if (!product)
        return res.status(404).json({ error: 'Product not found' });
    res.json(product);
});
export default router;
