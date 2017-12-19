# Failed with Python 3.x !!!
import tensorflow as tf
import numpy as np
from bregman.suite import *

k = 2
max_iterations = 100

# filenames = tf.train.match_filenames_once('*.wav')
filenames = ['audio_cough_1.wav']
count_num_files = tf.size(filenames)
filename_queue = tf.train.string_input_producer(filenames)
reader = tf.WholeFileReader()
filename, file_contents = reader.read(filename_queue)

chromo = tf.placeholder(tf.float32)
max_freqs = tf.argmax(chromo, 0)

def get_next_chromogram(sess):
  audio_file = sess.run(filename)
  print('Loading {}'.format(audio_file))
  F = Chromagram(audio_file, nfft=16384, wfft=8192, nhop=2205)
  return F.x, audio_file

def extract_feature_vector(sess, chromo_data):
  num_features, num_samples = np.shape(chromo_data)
  freq_vals = sess.run(max_freqs, feed_dict={chromo: chromo_data})
  hist, bins = np.histogram(freq_vals, bins=range(num_features + 1))
  normalized_hist = hist.astype(float) / num_samples
  return normalized_hist
  
def get_dataset(sess):
  num_files = sess.run(count_num_files)
  coord = tf.train.Coordinator()
  threads = tf.train.start_queue_runners(coord=coord)
  xs = list()
  names = list()
    
  for _ in range(num_files):
    plt.figure()
    chromo_data, filename = get_next_chromogram(sess)

    plt.subplot(1, 2, 1)
    #DAV>>> Failed!!! plt.imshow(chromo_data, cmap='Greys', interpolation='nearest')
    plt.title('Visualization of Sound Spectrum')

    plt.subplot(1, 2, 2)
    freq_vals = sess.run(max_freqs, feed_dict={chromo: chromo_data})
    plt.hist(freq_vals)
    plt.title('Histogram of Notes')
    plt.xlabel('Musical Note')
    plt.ylabel('Count')
    plt.savefig('{}.png'.format(filename))
    plt.show()

    names.append(filename)
    x = extract_feature_vector(sess, chromo_data)
    xs.append(x)
  xs = np.asmatrix(xs)
  coord.request_stop()
  coord.join(threads)
  return xs, names

def initial_cluster_centroids(X, k):
  return X[0:k, :]

def assign_cluster(X, centroids):
  expanded_vectors = tf.expand_dims(X, 0)
  expanded_centroids = tf.expand_dims(centroids, 1)
  distances = tf.reduce_sum(tf.square(tf.subtract(expanded_vectors, expanded_centroids)), 2)
  mins = tf.argmin(distances, 0)
  return mins

def recompute_centroids(X, Y):
  sums = tf.unsorted_segment_sum(X, Y, k)
  counts = tf.unsorted_segment_sum(tf.ones_like(X), Y, k)
  return sums / counts

with tf.Session() as sess:
  sess.run(tf.global_variables_initializer())
  X, names = get_dataset(sess)
  centroids = initial_cluster_centroids(X, k)
  i, converged = 0, False
  while not converged and i < max_iterations:
    i += 1
    Y = assign_cluster(X, centroids)
    centroids = sess.run(recompute_centroids(X, Y))
  print(zip(sess.run(Y), names))  
 