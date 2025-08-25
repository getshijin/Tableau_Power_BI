import kagglehub

# Download latest version
path = kagglehub.dataset_download("sukhmandeepsinghbrar/housing-price-dataset")

print("Path to dataset files:", path)