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

    // Validate each item, resolve its farmer, and ensure enough stock exists.
    const ordersByFarmer = new Map();
    for (const item of items) {
      const qty = parseFloat(item.quantity);
      if (isNaN(qty) || qty <= 0) return res.status(400).json({ message: 'Invalid item quantity' });
      const product = await Product.findById(item.productId);
      if (!product) return res.status(400).json({ message: `Product ${item.productId} not found` });
      if (product.quantity < qty) return res.status(400).json({ message: `Insufficient stock for ${product.name}` });

      const farmerKey = product.farmerId.toString();
      if (!ordersByFarmer.has(farmerKey)) {
        ordersByFarmer.set(farmerKey, {
          farmerId: product.farmerId,
          items: [],
          totalAmount: 0,
        });
      }

      const farmerOrder = ordersByFarmer.get(farmerKey);
      farmerOrder.items.push({
        productId: product._id,
        productName: product.name,
        quantity: qty,
        price: product.price,
      });
      farmerOrder.totalAmount += product.price * qty;
    }

    const createdOrders = [];
    for (const farmerOrder of ordersByFarmer.values()) {
      const order = new Order({
        buyerId: req.user.id,
        farmerId: farmerOrder.farmerId,
        items: farmerOrder.items,
        totalAmount: farmerOrder.totalAmount,
        deliveryAddress,
        status: 'pending',
      });
      await order.save();
      createdOrders.push(order);
    }

    // Decrease product quantities using conditional updates to avoid race issues.
    // If any decrement fails (not enough stock at update time), roll back previous decrements and return error.
    const updatedProducts = [];
    try {
      for (const item of items) {
        const qty = parseFloat(item.quantity);
        const updated = await Product.findOneAndUpdate(
          { _id: item.productId, quantity: { $gte: qty } },
          { $inc: { quantity: -qty } },
          { new: true }
        );
        if (!updated) {
          // Not enough stock at update time
          throw new Error(`Insufficient stock for product ${item.productId}`);
        } else {
        }
        updatedProducts.push({ id: item.productId, qty });
      }
    } catch (updateErr) {
      // Roll back any successful decrements
      for (const p of updatedProducts) {
        await Product.findByIdAndUpdate(p.id, { $inc: { quantity: p.qty } });
      }
      // Delete the created orders since we couldn't apply all decrements
      for (const order of createdOrders) {
        await Order.findByIdAndDelete(order._id);
      }
      return res.status(400).json({ message: updateErr.message });
    }

    res.status(201).json({ orders: createdOrders });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get orders for current user (buyer or farmer)
router.get('/', auth, async (req, res) => {
  try {
    const { page = 1, limit = 10 } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);
    let filter = {};
    if (req.user.role === 'farmer') filter.farmerId = req.user.id;
    else if (req.user.role === 'buyer') filter.buyerId = req.user.id;
    // admin sees all

    const orders = await Order.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));
    const total = await Order.countDocuments(filter);

    res.json({
      orders,
      total,
      page: parseInt(page),
      totalPages: Math.ceil(total / parseInt(limit))
    });
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

    // Check permissions:
    // - admin can change any status
    // - farmer (owner) can change status for their orders
    // - buyer can only mark their own order as 'delivered'
    const requestedStatus = String(status);
    const isAdmin = req.user.role === 'admin';
    const isFarmerOwner = req.user.role === 'farmer' && order.farmerId.toString() === req.user.id;
    const isBuyerOwnerDeliver = req.user.role === 'buyer' && order.buyerId.toString() === req.user.id && requestedStatus === 'delivered';

    if (!(isAdmin || isFarmerOwner || isBuyerOwnerDeliver)) {
      return res.status(403).json({ message: 'Not authorized to change status' });
    }

    order.status = requestedStatus;
    await order.save();
    res.json({ order });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;