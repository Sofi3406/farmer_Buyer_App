const router = require('express').Router();
const Product = require('../models/Product');
const auth = require('../middleware/auth');
const roleCheck = require('../middleware/roleCheck');

// Get all products with filters
router.get('/', async (req, res) => {
  try {
    const { search, location } = req.query;
    let filter = {};

    if (search) {
      filter.name = { $regex: search, $options: 'i' };
    }
    if (location) {
      filter.location = { $regex: location, $options: 'i' };
    }

    const products = await Product.find(filter).sort({ createdAt: -1 });
    res.json({ products });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get single product
router.get('/:id', async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) return res.status(404).json({ message: 'Product not found' });
    res.json({ product });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Add product (farmers only)
router.post('/', auth, roleCheck('farmer'), async (req, res) => {
  try {
    const product = new Product({
      ...req.body,
      farmerId: req.user.id,
      farmerName: req.user.name || 'Farmer', // you can fetch name from DB
    });
    await product.save();
    res.status(201).json({ product });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update product (owner only)
router.put('/:id', auth, roleCheck('farmer'), async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) return res.status(404).json({ message: 'Product not found' });
    if (product.farmerId.toString() !== req.user.id) {
      return res.status(403).json({ message: 'Not authorized to edit this product' });
    }
    Object.assign(product, req.body);
    await product.save();
    res.json({ product });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Delete product (owner or admin)
router.delete('/:id', auth, async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) return res.status(404).json({ message: 'Product not found' });
    if (product.farmerId.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not authorized' });
    }
    await product.deleteOne();
    res.json({ message: 'Product deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;