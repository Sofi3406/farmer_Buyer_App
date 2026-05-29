const router = require('express').Router();
const Product = require('../models/Product');
const User = require('../models/User');
const auth = require('../middleware/auth');
const roleCheck = require('../middleware/roleCheck');

// Get all products with filters, search, pagination
router.get('/', async (req, res) => {
  try {
    const { search, location, minPrice, maxPrice, category, farmerId, page = 1, limit = 10 } = req.query;
    let filter = {};

    if (search) filter.name = { $regex: search, $options: 'i' };
    if (location) filter.location = { $regex: location, $options: 'i' };
    if (category) filter.category = category;
    if (farmerId) filter.farmerId = farmerId;
    if (minPrice || maxPrice) {
      filter.price = {};
      if (minPrice) filter.price.$gte = parseFloat(minPrice);
      if (maxPrice) filter.price.$lte = parseFloat(maxPrice);
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);
    // populate farmerId.name so we can use it if farmerName was not set
    const products = await Product.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit))
      .populate('farmerId', 'name');

    const total = await Product.countDocuments(filter);

    // ensure each product has a farmerName (fallback to populated user name)
    const out = products.map(p => {
      const obj = p.toObject();
      if (!obj.farmerName || obj.farmerName === 'Farmer') {
        obj.farmerName = p.farmerId && p.farmerId.name ? p.farmerId.name : 'Farmer';
      }
      // if farmerId was populated, keep only the id
      obj.farmerId = obj.farmerId && obj.farmerId._id ? obj.farmerId._id : obj.farmerId;
      return obj;
    });

    res.json({
      products: out,
      total,
      page: parseInt(page),
      totalPages: Math.ceil(total / parseInt(limit))
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get single product
router.get('/:id', async (req, res) => {
  try {
    let product = await Product.findById(req.params.id).populate('farmerId', 'name');
    if (!product) return res.status(404).json({ message: 'Product not found' });
    const obj = product.toObject();
    if (!obj.farmerName || obj.farmerName === 'Farmer') {
      obj.farmerName = product.farmerId && product.farmerId.name ? product.farmerId.name : 'Farmer';
    }
    obj.farmerId = obj.farmerId && obj.farmerId._id ? obj.farmerId._id : obj.farmerId;
    res.json({ product: obj });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Add product (farmers only)
router.post('/', auth, roleCheck('farmer'), async (req, res) => {
  try {
    // fetch the user to obtain the current name (token may not include name)
    const user = await User.findById(req.user.id);
    const product = new Product({
      ...req.body,
      farmerId: req.user.id,
      farmerName: (user && user.name) ? user.name : 'Farmer',
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