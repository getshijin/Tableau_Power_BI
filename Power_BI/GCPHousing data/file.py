import kagglehub

# Download latest version
path = kagglehub.dataset_download("martinfrederiksen/danish-residential-housing-prices-1992-2024")

print("Path to dataset files:", path)