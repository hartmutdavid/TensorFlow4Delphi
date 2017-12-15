# # Saving Variables in TensorFlow

import tensorflow as tf
sess = tf.InteractiveSession()

# Create a boolean vector called `spike` to locate a sudden spike in data.
# 
# Since all variables must be initialized, initialize the variable by calling `run()` on its `initializer`.
raw_data = [1., 2., 8., -1., 0., 5.5, 6., 13]
spikes = tf.Variable([False] * len(raw_data), name='spikes')
spikes.initializer.run()

# The saver op will enable saving and restoring
saver = tf.train.Saver()

# Loop through the data and update the spike variable when there is a significant increase 
for i in range(1, len(raw_data)):
  if raw_data[i] - raw_data[i-1] > 5:
    spikes_val = spikes.eval()
    spikes_val[i] = True
    updater = tf.assign(spikes, spikes_val)
    updater.eval()

filename = P4DProps.Value['save_filename']
save_path = saver.save(sess, filename)
print("spikes data saved in file: %s" % save_path)

sess.close()
