# Image Classification using Feature Extraction
Aman Taxali, Yung-Chun Lee, Anuj Dahiya

## Description
For our Stats 503 final project, we would like to use a combination of feature extraction and classification techniques discussed in class to group images.

## Methodology
Image feature extraction involves several steps - dimensionality reduction, feature extraction and feature selection. Each image observation can be seen as a large vector of features represented by the pixel information. This data needs a reduction of dimension and selection the important features. The final step is to use these features to train and test a classifier (like SVM).

## Models 
- Feature Extraction: PCA, LDA
- Feature Classification: SVM, KNN
- Black Box Models: CNN, Deep CNN

## Data Set
CIFAR-10 is an established dataset used for object recognition and computer vision problems. It consists of 60000 32x32 color images in 10 classes, with 6000 images per class. There are 50000 training images and 10000 test images. The 10 classes are {airplane, automobile, bird, deer, dog, frog, horse, ship, truck}. 
Source: https://www.cs.toronto.edu/~kriz/cifar.html
