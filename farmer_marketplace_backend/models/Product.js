const mongoose = require('mongoose');

const ProductSchema = new mongoose.Schema({
  farmerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  farmerName: { type: String, required: true },
  name: { type: String, required: true },
  price: { type: Number, required: true, min: 0 },
  quantity: { type: Number, required: true, min: 0 },
  location: { type: String, required: true },
  images: [{ type: String }],
  description: String,
}, { timestamps: true });

module.exports = mongoose.model('Product', ProductSchema);