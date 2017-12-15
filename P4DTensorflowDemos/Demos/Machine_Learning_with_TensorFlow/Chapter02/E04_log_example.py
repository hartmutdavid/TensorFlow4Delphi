import tensorflow as tf

x = tf.constant([[1, 2]])
neg_op = tf.negative(x)

with tf.Session(config=tf.ConfigProto(log_device_placement=True)) as sess:
  result = sess.run(neg_op)
  print(result)


