import tensorflow as tf
sess = tf.InteractiveSession()

x = tf.constant([[1., 2.]])
neg_op = tf.negative(x)

result = neg_op.eval()
print(result)

sess.close()
