const mongoose = require('mongoose');

const ProductSchema = new mongoose.Schema({
  farmerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  farmerName: { type: String, required: true },
  accountNumber: String,
  accountHolderName: String,
  name: { type: String, required: true },
  price: { type: Number, required: true, min: 0 },
  quantity: { type: Number, required: true, min: 0 },
  location: { type: String, required: true },
  images: [{ type: String }],
  description: String,
  category: { type: String, enum: ['vegetables', 'fruits', 'grains', 'dairy', 'meat', 'other'], default: 'other' },
}, { timestamps: true });


module.exports = mongoose.model('Product', ProductSchema);