import cv2
import numpy as np
from glob import glob
from sklearn.cluster import KMeans
from sklearn.svm import SVC
from sklearn.preprocessing import StandardScaler
from matplotlib import pyplot as plt
from skimage.feature import hog
from skimage import data, exposure
import time





class ImageHelpers:
    def __init__(self):
        self.sift_object = cv2.xfeatures2d.SIFT_create(nfeatures=100)
        #self.sift_object = cv2.xfeatures2d.SIFT_create(nfeatures=30)
        #self.sift_object = cv2.xfeatures2d.SIFT_create(nfeatures=10, sigma=1, edgeThreshold=100)

    def gray(self, image):
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        return gray

    def features(self, image):
        ###################
        # SIFT
        ###################
        keypoints, descriptors = self.sift_object.detectAndCompute(image, None)
        #new_img = cv2.drawKeypoints(image, keypoints, None,
        #                        flags=cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS)
        # cv2.imwrite('sift_keypoints.jpg', new_img)

        key_points = np.zeros((image.shape[0], image.shape[1]))
        for keypoint in keypoints:
            kp_center = (int(round(keypoint.pt[0])), int(round(keypoint.pt[1])))
            kp_radius = int(round(keypoint.size))
            for i in range(kp_center[1]-kp_radius, kp_center[1]+kp_radius):
                y_cord = np.minimum(i, image.shape[1]-1)
                x_lo_cord = np.maximum(kp_center[0] - kp_radius, 0)
                x_hi_cord = np.minimum(kp_center[0] + kp_radius, image.shape[0]-1)
                key_points[y_cord, x_lo_cord:x_hi_cord] = \
                    image[y_cord, x_lo_cord:x_hi_cord]
        # cv2.imwrite("keypoints_only.jpg", key_points)

        ####################
        # HOG
        ####################
        descriptors, hog_img = hog(key_points, orientations=8, pixels_per_cell=(12, 12),
                                   cells_per_block=(2, 2),
                                   visualise=True, block_norm='L2')

        fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize=(8, 4),
                                       sharex=True,
                                       sharey=True)
        ax1.axis('off')
        ax1.imshow(image, cmap=plt.cm.gray)
        ax1.set_title('Input image')

        ax2.axis('off')
        ax2.imshow(key_points, cmap=plt.cm.gray)
        ax2.set_title('SIFT Features')

        hog_image_rescaled = exposure.rescale_intensity(hog_img,
                                                       in_range=(0, 10))
        ax3.axis('off')
        ax3.imshow(hog_image_rescaled, cmap=plt.cm.gray)
        ax3.set_title('Histogram of Oriented Gradients')
        plt.show()

        descriptors = np.array(descriptors)
        non_zero_descriptors = np.nonzero(descriptors)
        non_zero_descriptors = np.dstack((non_zero_descriptors, descriptors[non_zero_descriptors]))
        non_zero_descriptors = np.squeeze(non_zero_descriptors, axis=0)

        descriptors = non_zero_descriptors
        keypoints = non_zero_descriptors.shape[0]

        return [keypoints, descriptors]


class BOVHelpers:
    def __init__(self, n_clusters=20):
        self.n_clusters = n_clusters
        self.kmeans_obj = KMeans(n_clusters=n_clusters, verbose=False, n_jobs=1)
        self.kmeans_ret = None
        self.descriptor_vstack = None
        self.mega_histogram = None
        self.clf = SVC()

    def cluster(self):
        """
        cluster using KMeans algorithm,

        """
        start = time.time()
        print("Clustering...")
        self.kmeans_ret = self.kmeans_obj.fit_predict(self.descriptor_vstack)
        print("Done clustering...", time.time()-start, "seconds")

    def developVocabulary(self, n_images, descriptor_list, kmeans_ret=None):

        """
        Each cluster denotes a particular visual word
        Every image can be represeted as a combination of multiple
        visual words. The best method is to generate a sparse histogram
        that contains the frequency of occurence of each visual word

        Thus the vocabulary comprises of a set of histograms of encompassing
        all descriptions for all images

        """
        print("Creating vocabulary histogram...")
        self.mega_histogram = np.array(
            [np.zeros(self.n_clusters) for i in range(n_images)])
        old_count = 0
        for i in range(n_images):
            if descriptor_list[i] is None:
                l = 0
            else:
                l = len(descriptor_list[i])
            for j in range(l):
                if kmeans_ret is None:
                    if old_count + j == len(self.kmeans_ret):
                        print(j, l)
                        old_count -= 1
                    idx = self.kmeans_ret[old_count + j]
                else:
                    idx = kmeans_ret[old_count + j]
                self.mega_histogram[i][idx] += 1
            old_count += l
        print("Vocabulary Histogram Generated")

    def standardize(self, std=None):
        """

        standardize is required to normalize the distribution
        wrt sample size and features. If not normalized, the classifier may become
        biased due to steep variances.

        """
        if std is None:
            self.scale = StandardScaler().fit(self.mega_histogram)
            self.mega_histogram = self.scale.transform(self.mega_histogram)
        else:
            print("STD not none. External STD supplied")
            self.mega_histogram = std.transform(self.mega_histogram)

    def formatND(self, l):
        """
        restructures list into vstack array of shape
        M samples x N features for sklearn

        """
        vStack = np.array(l[0])
        counter = 0
        for remaining in l[1:]:
            counter += 1
            if remaining is None:
                continue
            vStack = np.vstack((vStack, remaining))
            if not (counter % 1000):
                print("Reshaping feature row", counter)
        self.descriptor_vstack = vStack.copy()
        print("Stack formatting completed...")
        return vStack

    def train(self, train_labels):
        """
        uses sklearn.svm.SVC classifier (SVM)


        """
        print("Training SVM")
        print(self.clf)
        print("Train labels", train_labels)
        self.clf.fit(self.mega_histogram, train_labels)
        print("Training completed")

    def predict(self, iplist):
        predictions = self.clf.predict(iplist)
        return predictions

    def plotHist(self, vocabulary=None):
        print("Plotting histogram")
        if vocabulary is None:
            vocabulary = self.mega_histogram

        x_scalar = np.arange(self.n_clusters)
        y_scalar = np.array(
            [abs(np.sum(vocabulary[:, h], dtype=np.int32)) for h in
             range(self.n_clusters)])

        print(y_scalar)

        plt.bar(x_scalar, y_scalar)
        plt.xlabel("Visual Word Index")
        plt.ylabel("Frequency")
        plt.title("Complete Vocabulary Generated")
        plt.xticks(x_scalar + 0.4, x_scalar)
        plt.show()


class FileHelpers:
    def __init__(self):
        pass

    def getFiles(self, path, limit=None):
        """
        - returns  a dictionary of all files
        having key => value as  objectname => image path

        - returns total number of files.

        """
        imlist = {}
        count = 0
        for each in glob(path + "*"):
            word = each.split("\\")[-1]
            print("#### Reading image category", word, "#####")
            imlist[word] = []
            for imagefile in glob(path + word + "/*"):
                #print("Reading file ", imagefile)
                im = cv2.imread(imagefile, 0)
                height, width = im.shape
                if height != 300 or width != 400:
                    # print("Bad file", imagefile, "height:", height, "width:", width)
                    im = cv2.resize(im, (300, 400))
                if limit:
                    if len(imlist[word]) >= limit:
                        continue
                    else:
                        imlist[word].append(im)
                else:
                    imlist[word].append(im)
                count += 1

        return [imlist, count]
