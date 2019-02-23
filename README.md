# NBS-Predict

NBS-Predict is a new approach that combines the powerful features of machine learning and network-based statistics. 
By combining a nested cross-validation structure with advanced machine learning models, NBS-Predict aims to close the gap between group-level analysis and subject-specific prediction based on individually important network variations.

# Briefly, 
NBS-Predict operates in a core standard 2-step nested cross-validation structure (K-fold or leave-one-out). The outer loop is used to evaluate a learning model performance (i.e., out of sample prediction estimate of a graph component), while suprathreshold link optimization, which is similar to feature selection, is carried out in the middle loop. An optional third inner loop, in which hyperparameters for a learning model are optimized, will also be available.

A work in progress by Emin Serin
