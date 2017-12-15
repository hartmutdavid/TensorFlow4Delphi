# # Using Variables in TensorFlow

import tensorflow as tf
sess = tf.InteractiveSession()

# Create a boolean variable called `spike` to detect sudden a sudden increase in a series of numbers.
# 
# Since all variables must be initialized, initialize the variable by calling `run()` on its `initializer`.
raw_data = [1., 2., 8., -1., 0., 5.5, 6., 13]
spike = tf.Variable(False)
spike.initializer.run()

# Loop through the data and update the spike variable when there is a significant increase 
for i in range(1, len(raw_data)):
  if raw_data[i] - raw_data[i-1] > 5:
    updater = tf.assign(spike, tf.constant(True))
    updater.eval()
  else:
    tf.assign(spike, False).eval()
  print("Spike", spike.eval())

sess.close()
