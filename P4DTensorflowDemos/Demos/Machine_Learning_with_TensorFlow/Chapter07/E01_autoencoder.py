# 
import tensorflow as tf
import numpy as np
from sklearn import datasets

def get_batch(X, size):
  a = np.random.choice(len(X), size, replace=False)
  return X[a]

class Autoencoder:
  def __init__(self, input_dim, hidden_dim, epoch=500, batch_size=10, learning_rate=0.001):
    self.epoch = epoch
    self.batch_size = batch_size
    self.learning_rate = learning_rate

    # Define input placeholder
    x = tf.placeholder(dtype=tf.float32, shape=[None, input_dim])
    
    # Define variables
    with tf.name_scope('encode'):
      weights = tf.Variable(tf.random_normal([input_dim, hidden_dim], dtype=tf.float32), name='weights')
      biases = tf.Variable(tf.zeros([hidden_dim]), name='biases')
      encoded = tf.nn.sigmoid(tf.matmul(x, weights) + biases)
    with tf.name_scope('decode'):
      weights = tf.Variable(tf.random_normal([hidden_dim, input_dim], dtype=tf.float32), name='weights')
      biases = tf.Variable(tf.zeros([input_dim]), name='biases')
      decoded = tf.matmul(encoded, weights) + biases

    self.x = x
    self.encoded = encoded
    self.decoded = decoded

    # Define cost function and training op
    self.loss = tf.sqrt(tf.reduce_mean(tf.square(tf.subtract(self.x, self.decoded))))

    self.all_loss = tf.sqrt(tf.reduce_mean(tf.square(tf.subtract(self.x, self.decoded)), 1))
    self.train_op = tf.train.AdamOptimizer(self.learning_rate).minimize(self.loss)
    
    # Define a saver op
    self.saver = tf.train.Saver()

  def train(self, data):
    with tf.Session() as sess:
      sess.run(tf.global_variables_initializer())
      for i in range(self.epoch):
        for j in range(500):
          batch_data = get_batch(data, self.batch_size)
          l, _ = sess.run([self.loss, self.train_op], feed_dict={self.x: batch_data})
        if i % 50 == 0:
          print('epoch {0}: loss = {1}'.format(i, l))
          self.saver.save(sess, './model.ckpt')
      self.saver.save(sess, './model.ckpt')
        
  def test(self, data):
    with tf.Session() as sess:
      self.saver.restore(sess, './model.ckpt')
      hidden, reconstructed = sess.run([self.encoded, self.decoded], feed_dict={self.x: data})
    print('input', data)
    print('compressed', hidden)
    print('reconstructed', reconstructed)
    return reconstructed

  def get_params(self):
    with tf.Session() as sess:
      self.saver.restore(sess, './model.ckpt')
      weights, biases = sess.run([self.weights1, self.biases1])
    return weights, biases

  def classify(self, data, labels):
    with tf.Session() as sess:
      sess.run(tf.global_variables_initializer())
      self.saver.restore(sess, './model.ckpt')
      hidden, reconstructed = sess.run([self.encoded, self.decoded], feed_dict={self.x: data})
      reconstructed = reconstructed[0]
      # loss = sess.run(self.all_loss, feed_dict={self.x: data})
      print('data', np.shape(data))
      print('reconstructed', np.shape(reconstructed))
      loss = np.sqrt(np.mean(np.square(data - reconstructed), axis=1))
      print('loss', np.shape(loss))
      horse_indices = np.where(labels == 7)[0]
      not_horse_indices = np.where(labels != 7)[0]
      horse_loss = np.mean(loss[horse_indices])
      not_horse_loss = np.mean(loss[not_horse_indices])
      print('horse', horse_loss)
      print('not horse', not_horse_loss)
      return hidden[7,:]

  def decode(self, encoding):
    with tf.Session() as sess:
      sess.run(tf.global_variables_initializer())
      self.saver.restore(sess, './model.ckpt')
      reconstructed = sess.run(self.decoded, feed_dict={self.encoded: encoding})
    img = np.reshape(reconstructed, (32, 32))
    return img
        
hidden_dim = 1
data = datasets.load_iris().data
input_dim = len(data[0])
ae = Autoencoder(input_dim, hidden_dim)
ae.train(data)
ae.test([[8, 4, 6, 2]])
        

    