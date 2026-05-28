const router = require('express').Router();
const Order = require('../models/Order');
const Product = require('../models/Product');
const auth = require('../middleware/auth');
const roleCheck = require('../middleware/roleCheck');

// Place an order (buyer)
router.post('/', auth, roleCheck('buyer'), async (req, res) => {
  try {
    const { items, totalAmount, deliveryAddress } = req.body;
    if (!items || items.length === 0) {
      return res.status(400).json({ message: 'Cart is empty' });
    }

    // Get farmerId from the first product (assuming all from same farmer)
    const firstProduct = await Product.findById(items[0].productId);
    if (!firstProduct) return res.status(400).json({ message: 'Product not found' });

    const farmerId = firstProduct.farmerId;
    // For simplicity, we assume all items belong to same farmer. 
    // In a real app, you'd handle multiple farmers separately.

    const order = new Order({
      buyerId: req.user.id,
      farmerId,
      items,
      totalAmount,
      deliveryAddress,
      status: 'pending',
    });
    await order.save();

    // Decrease product quantities
    for (let item of items) {
      await Product.findByIdAndUpdate(item.productId, {
        $inc: { quantity: -item.quantity }
      });
    }

    res.status(201).json({ order });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get orders for current user (buyer or farmer)
router.get('/', auth, async (req, res) => {
  try {
    let orders;
    if (req.user.role === 'farmer') {
      orders = await Order.find({ farmerId: req.user.id }).sort({ createdAt: -1 });
    } else if (req.user.role === 'buyer') {
      orders = await Order.find({ buyerId: req.user.id }).sort({ createdAt: -1 });
    } else if (req.user.role === 'admin') {
      orders = await Order.find().sort({ createdAt: -1 });
    } else {
      return res.status(403).json({ message: 'Invalid role' });
    }
    res.json({ orders });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update order status (farmer or admin)
router.put('/:id/status', auth, async (req, res) => {
  try {
    const { status } = req.body;
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: 'Order not found' });

    // Check permissions
    if (order.farmerId.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not authorized' });
    }

    order.status = status;
    await order.save();
    res.json({ order });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;