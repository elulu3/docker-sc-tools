# Dockerfile for the Seurat 4.1.0
FROM rocker/r-ubuntu:22.04

# Set global R options
RUN echo "options(repos = 'https://cloud.r-project.org')" > $(R --no-echo --no-save -e "cat(Sys.getenv('R_HOME'))")/etc/Rprofile.site
ENV RETICULATE_MINICONDA_ENABLED=FALSE

# Install Seurat's system dependencies
RUN apt-get update
RUN apt-get install -y \
    libhdf5-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libpng-dev \
    libboost-all-dev \
    libxml2-dev \
    openjdk-8-jdk \
    python3-dev \
    python3-pip \
    wget \
    git \
    libfftw3-dev \
    libgsl-dev \
    libgeos-dev \
    libudunits2-dev \
    libgdal-dev \
    cmake   

RUN apt-get install -y llvm-11

# Install UMAP
RUN LLVM_CONFIG=/usr/lib/llvm-11/bin/llvm-config pip3 install llvmlite
RUN pip3 install numpy
RUN pip3 install umap-learn

# Install FIt-SNE
RUN git clone --branch v1.2.1 https://github.com/KlugerLab/FIt-SNE.git
RUN g++ -std=c++11 -O3 FIt-SNE/src/sptree.cpp FIt-SNE/src/tsne.cpp FIt-SNE/src/nbodyfft.cpp  -o bin/fast_tsne -pthread -lfftw3 -lm

# Install bioconductor dependencies & suggests
RUN R --no-echo -e "install.packages('BiocManager')" && \
    R --no-echo -e "BiocManager::install(c('scuttle', 'scran', 'scater', 'DropletUtils', 'org.Hs.eg.db', 'phyloseq', 'org.Mm.eg.db', 'scDblFinder', 'batchelor', 'Biobase', 'BiocGenerics', 'DESeq2', 'DelayedArray', 'DelayedMatrixStats', 'GenomicRanges', 'glmGamPoi', 'IRanges', 'limma', 'MAST', 'Matrix.utils', 'multtest', 'rtracklayer', 'S4Vectors', 'SingleCellExperiment', 'SummarizedExperiment'))" && \
    R --no-echo -e "install.packages(c('shiny', 'spdep', 'rgeos', 'VGAM', 'R.utils', 'metap', 'Rfast2', 'ape', 'enrichR', 'mixtools', 'tidyverse', 'argparse', 'jsonlite', 'uwot', 'optparse'))" && \
    R --no-echo -e "install.packages(c('hdf5r', 'remotes', 'Seurat', 'devtools'))" && \
    R --no-echo -e "remotes::install_github('mojaveazure/seurat-disk')" && \
    R --no-echo -e "devtools::install_github('cole-trapnell-lab/leidenbase')" && \
    R --no-echo -e "devtools::install_github('cole-trapnell-lab/monocle3')" && \
    R --no-echo -e "devtools::install_github('cole-trapnell-lab/garnett', ref='monocle3')" && \
    R --no-echo -e "devtools::install_github('ncborcherding/scRepertoire@dev')" && \
    R --no-echo -e "devtools::install_github('adw96/breakaway')" && \
    R --no-echo -e "devtools::install_github('WarrenLabFH/LymphoSeq2', ref='v1', build_vignette=FALSE)"