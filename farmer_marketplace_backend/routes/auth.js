const router = require('express').Router();
const User = require('../models/User');
const generateToken = require('../utils/generateToken');

// Register
router.post('/register', async (req, res) => {
  try {
    const { name, email, password, role, phone, location, farmDetails } = req.body;

    // Check if user exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'User already exists' });
    }

    // Create new user
    const user = new User({
      name,
      email,
      password,
      role: role || 'buyer',
      phone,
      location,
      farmDetails,
    });
    await user.save();

    const token = generateToken(user);
    res.status(201).json({
      token,
      user: {
        _id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        phone: user.phone,
        location: user.location,
        farmDetails: user.farmDetails,
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const token = generateToken(user);
    res.json({
      token,
      user: {
        _id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        phone: user.phone,
        location: user.location,
        farmDetails: user.farmDetails,
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Forgot password (simple placeholder)
router.post('/forgot-password', async (req, res) => {
  const { email } = req.body;
  // In production: send email with reset link
  res.json({ message: 'If that email exists, a reset link has been sent.' });
});

module.exports = router;