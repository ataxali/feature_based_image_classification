import pickle
import sys
import load_cifar


def unpickle(file):
    with open(file, 'rb') as fo:
        dict = pickle.load(fo, encoding='bytes')
    return dict


dat = unpickle('./data/cifar-10/data_batch_1')
print(dat.keys())
print((dat[b'data'].shape))

print(len(pickle.dumps(dat, -1)))
print(sys.getsizeof(pickle.dumps(dat)))

imagearray, labelarray = load_cifar.load_batch()
metaarray = load_cifar.load_meta()
load_cifar.cifar10_plot(imagearray, labelarray, metaarray)
