# 
from matplotlib import pyplot as plt
import pickle
import numpy as np
from autoencoder import Autoencoder

def unpickle(file):
  fo = open(file, 'rb')
  dict = pickle.load(fo, encoding='latin1')
  fo.close()
  return dict

def grayscale(a):
  return a.reshape(a.shape[0], 3, 32, 32).mean(1).reshape(a.shape[0], -1)
	
names = unpickle('./cifar-10-batches-py/batches.meta')['label_names']
data, labels = [], []
for i in range(1, 6):
  filename = './cifar-10-batches-py/data_batch_' + str(i)
  batch_data = unpickle(filename)
  if len(data) > 0:
    data = np.vstack((data, batch_data['data']))
    labels = np.hstack((labels, batch_data['labels']))
  else:
    data = batch_data['data']
    labels = batch_data['labels']

data = grayscale(data)
x = np.matrix(data)
y = np.array(labels)

horse_indices = np.where(y == 7)[0]
horse_x = x[horse_indices]
print(np.shape(horse_x))  # (5000, 3072)

print('Some examples of horse images we will feed to the autoencoder for training')
plt.rcParams['figure.figsize'] = (10, 10)
num_examples = 5
for i in range(num_examples):
  horse_img = np.reshape(horse_x[i, :], (32, 32))
  plt.subplot(1, num_examples, i+1)
  plt.imshow(horse_img, cmap='Greys_r')
plt.show()

input_dim = np.shape(horse_x)[1]
hidden_dim = 100
ae = Autoencoder(input_dim, hidden_dim)
ae.train(horse_x)

test_data = unpickle('./cifar-10-batches-py/test_batch')
test_x = grayscale(test_data['data'])
test_labels = np.array(test_data['labels'])
encodings = ae.classify(test_x, test_labels)

plt.rcParams['figure.figsize'] = (100, 100)
plt.figure()
for i in range(20):
  plt.subplot(20, 2, i*2 + 1)
  original_img = np.reshape(test_x[i, :], (32, 32))
  plt.imshow(original_img, cmap='Greys_r')
    
  plt.subplot(20, 2, i*2 + 2)
  reconstructed_img = ae.decode([encodings[i]])
  plt.imshow(reconstructed_img, cmap='Greys_r')

plt.show()

