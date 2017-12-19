# 
import tensorflow as tf
import numpy as np
from bregman.suite import *

k = 2
segment_size = 50
max_iterations = 100

chromo = tf.placeholder(tf.float32)
max_freqs = tf.argmax(chromo, 0)

def get_chromogram(audio_file):
  F = Chromagram(audio_file, nfft=16384, wfft=8192, nhop=2205)
  return F.X

def get_dataset(sess, audio_file):
  chromo_data = get_chromogram(audio_file)
  print('chromo_data', np.shape(chromo_data))
  chromo_length = np.shape(chromo_data)[1]
  print('  chromo_length=', chromo_length, 'segment_size=', segment_size)
  xs = []
  for i in range(chromo_length//segment_size):
    chromo_segment = chromo_data[:, i*segment_size:(i+1)*segment_size]
    x = extract_feature_vector(sess, chromo_segment)
    if len(xs) == 0:
      xs = x
    else:
      xs = np.vstack((xs, x))
  return xs

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

def extract_feature_vector(sess, chromo_data):
  num_features, num_samples = np.shape(chromo_data)
  freq_vals = sess.run(max_freqs, feed_dict={chromo: chromo_data})
  hist, bins = np.histogram(freq_vals, bins=range(num_features + 1))
  return hist.astype(float) / num_samples

with tf.Session() as sess:
  X = get_dataset(sess, 'TalkingMachinesPodcast.wav')
  print(np.shape(X))
  centroids = initial_cluster_centroids(X, k)
  i, converged = 0, False
  # prev_Y = None
  while not converged and i < max_iterations:
    i += 1
    Y = assign_cluster(X, centroids)
    # if prev_Y == Y:
    #     converged = True
    #     break
    # prev_Y = Y
    centroids = sess.run(recompute_centroids(X, Y))
    if i % 50 == 0:
      print('iteration', i)
  segments = sess.run(Y)
  for i in range(len(segments)):
    seconds = (i * segment_size) / float(20)
    min, sec = divmod(seconds, 60)
    time_str = str(min) + 'm ' + str(sec) + 's'
    print(time_str, segments[i])  
