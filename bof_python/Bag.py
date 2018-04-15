import cv2
import numpy as np
from glob import glob
import mnist
import argparse
from helpers import *
from matplotlib import pyplot as plt
from sklearn.decomposition import PCA
from sklearn import preprocessing
from sklearn.metrics import confusion_matrix

HOG_PCA_COMPONENTS = 100
TEST_IMAGE_LIMIT = 50
TRAIN_IMAGE_LIMIT = 100
VOCAB_SIZE = 200

class_hog_vectors = dict()
class_hog_means = dict()
class_hog_vars = dict()
class_hog_eig_vectors = dict()


class BOV:
    def __init__(self, no_clusters):
        self.no_clusters = no_clusters
        self.train_path = None
        self.test_path = None
        self.im_helper = ImageHelpers()
        self.bov_helper = BOVHelpers(no_clusters)
        self.file_helper = FileHelpers()
        self.images = None
        self.trainImageCount = 0
        self.train_labels = np.array([])
        self.name_dict = {}
        self.descriptor_list = []

    def trainModel(self):
        """
        This method contains the entire module 
        required for training the bag of visual words model

        Use of helper functions will be extensive.

        """

        # read file. prepare file lists.
        self.images, self.trainImageCount = self.file_helper.getFiles(
            self.train_path, limit=TRAIN_IMAGE_LIMIT)
        #self.images, self.trainImageCount = mnist.get_data("training", 1000)
        # extract SIFT Features from each image
        label_count = 0
        for word, imlist in self.images.items():
            self.name_dict[str(label_count)] = word
            print("Computing Features for", word)
            for im in imlist:
                # cv2.imshow("im", im)
                # cv2.waitKey()
                self.train_labels = np.append(self.train_labels, label_count)
                kp, des = self.im_helper.features(im)
                self.descriptor_list.append(des)
                if word in class_hog_vectors:
                    class_hog_vectors[word].append(des.tolist())
                else:
                    class_hog_vectors[word] = [des.tolist()]

            label_count += 1

        ##################
        # HOG-PCA Method
        ##################
        '''
        for c in class_hog_vectors.keys():
            pca = PCA(n_components=HOG_PCA_COMPONENTS, svd_solver='full')
            c_vecs = class_hog_vectors[c]
            c_X = np.array(c_vecs[0])
            for remaining in c_vecs[1:]:
                c_X = np.vstack((c_X, remaining))
            class_hog_means[c] = np.mean(c_X, axis=0)
            class_hog_vars[c] = np.var(c_X, axis=0)
            c_X = preprocessing.scale(c_X, with_mean=True, with_std=True, axis=0)
            pca.fit(c_X)
            class_hog_eig_vectors[c] = pca
        '''
        #####################
        # Bag of Features
        #####################
        # perform k-means clustering
        bov_descriptor_stack = self.bov_helper.formatND(self.descriptor_list)
        self.bov_helper.cluster()
        self.bov_helper.developVocabulary(n_images=self.trainImageCount,
                                          descriptor_list=self.descriptor_list)
        # show vocabulary trained
        self.bov_helper.plotHist()
        self.bov_helper.standardize()
        self.bov_helper.train(self.train_labels)

    def recognize(self, test_img, test_image_path=None):

        """ 
        This method recognizes a single image 
        It can be utilized individually as well.


        """

        kp, des = self.im_helper.features(test_img)

        if des is None: return ["Error"]
        ###################
        # hog-pca method
        ###################
        '''
        distances = dict()
        for c in class_hog_eig_vectors:
            c_X = np.array(des[0]) - class_hog_means[c]
            #with np.errstate(divide='ignore', invalid='ignore'):
            #    std_devs = np.sqrt(class_hog_vars[c])
            #    c_X = np.divide(c_X, std_devs, where=std_devs!=0)
            #c_X = np.nan_to_num(c_X)
            pca_proj = class_hog_eig_vectors[c].transform(np.resize(c_X, (1, len(c_X))))
            #pca_mean_proj = class_hog_eig_vectors[c].transform(np.resize(class_hog_means[c],
            #                                                             (1, len(class_hog_means[c]))))
            pca_inv_proj = class_hog_eig_vectors[c].inverse_transform(pca_proj)
            distances[c] = np.linalg.norm(des - (pca_inv_proj + class_hog_means[c]))

        # print(distances)

        min_dist = np.Inf
        min_class = None
        for c in distances:
            if distances[c] < min_dist:
                min_dist = distances[c]
                min_class = c

        for id, name in self.name_dict.items():
            if name == min_class:
                return id

        if min_class is None:
            return ['Error']
        '''


        ###########################
        # Bag of features method
        ###########################
        # print kp
        #print(des.shape)

        # generate vocab for test image
        vocab = np.array([[0 for i in range(self.no_clusters)]])
        # locate nearest clusters for each of 
        # the visual word (feature) present in the image

        # test_ret =<> return of kmeans nearest clusters for N features
        test_ret = self.bov_helper.kmeans_obj.predict(des)
        # print test_ret

        # print vocab
        for each in test_ret:
            vocab[0][each] += 1

        #print(vocab)
        # Scale the features
        vocab = self.bov_helper.scale.transform(vocab)

        # predict the class of the image
        lb = self.bov_helper.clf.predict(vocab)
        # print "Image belongs to class : ", self.name_dict[str(int(lb[0]))]
        return lb

    def testModel(self):
        """ 
        This method is to test the trained classifier

        read all images from testing path 
        use BOVHelpers.predict() function to obtain classes of each image

        """

        self.testImages, self.testImageCount = self.file_helper.getFiles(
            self.test_path, limit=TEST_IMAGE_LIMIT)
        #self.testImages, self.testImageCount = mnist.get_data("testing", 100)

        predictions = []
        true_values = []
        y_preds = []

        for word, imlist in self.testImages.items():
            print("processing ", word)
            for im in imlist:
                # print imlist[0].shape, imlist[1].shape
                #print(im.shape)
                cl = self.recognize(im)
                if cl[0] == "Error":
                    print("Could not classify ", word, im)
                    continue
                #print(cl)
                predictions.append({
                    'image': im,
                    'class': cl,
                    'object_name': self.name_dict[str(int(cl[0]))]
                })
                true_values.append(word)
                y_preds.append(self.name_dict[str(int(cl[0]))])

        # print(predictions)
        incorrect_classifications = 0
        correct_classifications = 0
        for i, each in enumerate(predictions):
            # cv2.imshow(each['object_name'], each['image'])
            # cv2.waitKey()
            # cv2.destroyWindow(each['object_name'])
            #
            if each['object_name'] != true_values[i]:
                #plt.imshow(cv2.cvtColor(each['image'], cv2.COLOR_GRAY2RGB))
                #plt.title(each['object_name'])
                #plt.show()
                incorrect_classifications += 1
            else:
                correct_classifications += 1

        print("Correct classifications", correct_classifications)
        print("Incorrect classifications", incorrect_classifications)
        print("Err pct", incorrect_classifications/(correct_classifications + incorrect_classifications))
        print(self.name_dict)
        print(confusion_matrix(true_values, y_preds, labels=['ball', 'car', 'money', 'motorbike', 'person']))


    def print_vars(self):
        pass


if __name__ == '__main__':
    # parse cmd args
    parser = argparse.ArgumentParser(
        description=" Bag of visual words example"
    )
    parser.add_argument('--train_path', action="store", dest="train_path",
                        required=True)
    parser.add_argument('--test_path', action="store", dest="test_path",
                        required=True)

    args = vars(parser.parse_args())
    print(args)

    bov = BOV(no_clusters=VOCAB_SIZE)

    # set training paths
    bov.train_path = args['train_path']
    # set testing paths
    bov.test_path = args['test_path']
    # train the model
    bov.trainModel()
    # test model
    bov.testModel()
