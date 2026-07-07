import zipfile

with zipfile.ZipFile("walmart-10k-sales-datasets.zip" , "r") as zip_ref:
    zip_ref.extractall(".")