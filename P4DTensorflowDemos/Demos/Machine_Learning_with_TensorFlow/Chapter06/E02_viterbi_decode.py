# 
import numpy as np
import tensorflow as tf

# initial parameters can be learned on training data
# theory reference https://web.stanford.edu/~jurafsky/slp3/8.pdf
# code reference https://phvu.net/2013/12/06/sweet-implementation-of-viterbi-in-python/
class HMM(object):
  def __init__(self, initial_prob, trans_prob, obs_prob):
    self.N = np.size(initial_prob)
    self.initial_prob = initial_prob
    self.trans_prob = trans_prob
    self.obs_prob = obs_prob
    self.emission = tf.constant(obs_prob)
    assert self.initial_prob.shape == (self.N, 1)
    assert self.trans_prob.shape == (self.N, self.N)
    assert self.obs_prob.shape[0] == self.N
    self.obs = tf.placeholder(tf.int32)
    self.fwd = tf.placeholder(tf.float64)
    self.viterbi = tf.placeholder(tf.float64)

  def get_emission(self, obs_idx):
    slice_location = [0, obs_idx]
    num_rows = tf.shape(self.emission)[0]
    slice_shape = [num_rows, 1]
    return tf.slice(self.emission, slice_location, slice_shape)

  def forward_init_op(self):
    obs_prob = self.get_emission(self.obs)
    fwd = tf.multiply(self.initial_prob, obs_prob)
    return fwd

  def forward_op(self):
    transitions = tf.matmul(self.fwd, tf.transpose(self.get_emission(self.obs)))
    weighted_transitions = transitions * self.trans_prob
    fwd = tf.reduce_sum(weighted_transitions, 0)
    return tf.reshape(fwd, tf.shape(self.fwd))

  def decode_op(self):
    transitions = tf.matmul(self.viterbi, tf.transpose(self.get_emission(self.obs)))
    weighted_transitions = transitions * self.trans_prob
    viterbi = tf.reduce_max(weighted_transitions, 0)
    return tf.reshape(viterbi, tf.shape(self.viterbi))

  def backpt_op(self):
    back_transitions = tf.matmul(self.viterbi, np.ones((1, self.N)))
    weighted_back_transitions = back_transitions * self.trans_prob
    return tf.argmax(weighted_back_transitions, 0)
        
def forward_algorithm(sess, hmm, observations):
  fwd = sess.run(hmm.forward_init_op(), feed_dict={hmm.obs: observations[0]})
  for t in range(1, len(observations)):
    fwd = sess.run(hmm.forward_op(), feed_dict={hmm.obs: observations[t], hmm.fwd: fwd})
  prob = sess.run(tf.reduce_sum(fwd))
  return prob
    
def viterbi_decode(sess, hmm, observations):
  viterbi = sess.run(hmm.forward_init_op(), feed_dict={hmm.obs: observations[0]})
  backpts = np.ones((hmm.N, len(observations)), 'int32') * -1
  for t in range(1, len(observations)):
    viterbi, backpt = sess.run([hmm.decode_op(), hmm.backpt_op()],
                                feed_dict={hmm.obs: observations[t],
                                           hmm.viterbi: viterbi})
    backpts[:, t] = backpt
  tokens = [viterbi[:, -1].argmax()]
  for i in range(len(observations) - 1, 0, -1):
    tokens.append(backpts[tokens[-1], i])
  return tokens[::-1]

if __name__ == '__main__':
  states = ('Healthy', 'Fever')
#     observations = ('normal', 'cold', 'dizzy')
#     start_probability = {'Healthy': 0.6, 'Fever': 0.4}
#     transition_probability = {
#         'Healthy': {'Healthy': 0.7, 'Fever': 0.3},
#         'Fever': {'Healthy': 0.4, 'Fever': 0.6}
#     }
#     emission_probability = {
#         'Healthy': {'normal': 0.5, 'cold': 0.4, 'dizzy': 0.1},
#         'Fever': {'normal': 0.1, 'cold': 0.3, 'dizzy': 0.6}
#     }
  initial_prob = np.array([[0.6], [0.4]])
  trans_prob = np.array([[0.7, 0.3], [0.4, 0.6]])
  obs_prob = np.array([[0.5, 0.4, 0.1], [0.1, 0.3, 0.6]])
  hmm = HMM(initial_prob=initial_prob, trans_prob=trans_prob, obs_prob=obs_prob)

  observations = [0, 1, 1, 2, 1]
  with tf.Session() as sess:
    prob = forward_algorithm(sess, hmm, observations)
    print('Probability of observing {} is {}'.format(observations, prob))

    seq = viterbi_decode(sess, hmm, observations)
    print('Most likely hidden states are {}'.format(seq))