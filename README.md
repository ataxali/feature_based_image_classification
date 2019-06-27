# Feature Based Image Classification

### Motivation
In this project, we explore a variety of supervised learning techniques for image classification. At the heart of our models are image feature descriptor algorithms from computer vision and image processing research. These algorithms are combined with dimensionality reduction and classification techniques such as PCA, SVM; and the strengths and weaknesses of each model are analysed separately for high and low-resolution image data sets. In the end, we propose a mixture of models technique that is able to classify both high and
low-resolution datasets with greater than 80% accuracy.


### Results
Please see [the included report](https://github.com/ataxali/feature_based_image_classification/blob/master/group9_report_wo_names.pdf) for more information on our methodology and experimental results. 
 - Section 1 covers a naive Nearest Neighbor Classifier
 - Section 2 combines the Histogram of Oriented Gradient (HOG) feature descriptor with PCA 
 - Section 3 combines the Scale-Invariant Feature Transform (SIFT) descriptor with SVM in a Bag-of-Features model 
 - Section 4 describes a hybrid model using the findings from previous sections

