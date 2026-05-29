require('dotenv').config();
const mongoose = require('mongoose');
const Product = require('../models/Product');

const MONGODB_URI = process.env.MONGODB_URI;
if (!MONGODB_URI) {
  console.error('Missing MONGODB_URI in environment');
  process.exit(1);
}

async function run() {
  await mongoose.connect(MONGODB_URI);
  console.log('Connected to MongoDB');

  const filter = {
    $or: [
      { accountNumber: { $exists: false } },
      { accountNumber: null },
      { accountNumber: '' }
    ]
  };

  const update = {
    $set: {
      accountNumber: '1000100100100 CBE',
      accountHolderName: 'FarmConnect'
    }
  };

  const res = await Product.updateMany(filter, update);
  // Compatible with different mongoose return shapes
  const matched = res.matchedCount ?? res.n ?? 0;
  const modified = res.modifiedCount ?? res.nModified ?? 0;
  console.log(`Products matched: ${matched}, modified: ${modified}`);

  await mongoose.disconnect();
  console.log('Disconnected. Migration complete.');
}

run().catch(err => {
  console.error('Migration failed:', err);
  process.exit(1);
});
