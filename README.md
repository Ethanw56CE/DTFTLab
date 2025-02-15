# **DTFTLab - Discrete-Time Fourier Transform Processing Library**

## **Overview**
DTFTLab is a MATLAB toolbox designed for **efficient processing of Discrete-Time Fourier Transform (DTFT) signals in the frequency domain**. This library provides functions for **DTFT computation, filtering, upsampling, downsampling, noise removal, and visualization**, making it an essential tool for **digital signal processing (DSP), spectral analysis, and research applications**.

## **Features**
✅ **DTFT Computation** - Compute the DTFT of a signal.
✅ **Inverse DTFT Reconstruction** - Convert DTFT spectra back to time-domain signals.
✅ **Filtering in Frequency Domain** - Apply low-pass, high-pass, and custom filters.
✅ **Upsampling and Downsampling** - Modify DTFT resolution while preserving spectral integrity.
✅ **Noise Reduction** - Remove outliers and smooth spectral data.
✅ **Frequency Shifting** - Shift signals in the frequency domain with phase control.
✅ **Comprehensive Visualization** - Plot DTFT spectra, magnitude, and complex components in 2D & 3D.
✅ **Optimized for Large Datasets** - Uses memory-efficient techniques for high-performance processing.

## **Installation**
### **Install via MATLAB Add-On Manager**
- Open **MATLAB** > Home > Add-Ons > Manage Add-Ons.
- Click **Install** and select `DTFTLab.mltbx`.
- MATLAB will automatically add the functions to the path.

### **Manual Installation** (if using source files)
If you downloaded the source code from GitHub:
```matlab
addpath(genpath('DTFTLab'))
savepath
```

## **Getting Started**
### **1Compute and Plot a DTFT**
```matlab
Fs = 1000;                      % Sampling frequency
t = (0:1/Fs:1-1/Fs);           % Time vector
x = cos(2*pi*50*t) + sin(2*pi*120*t); % Example signal

[X_dtft, omega] = dtft(x);     % Compute DTFT
magPlot(X_dtft, false, true, omega); % Plot magnitude spectrum
```

### **Apply a Low-Pass Filter**
```matlab
H = bestLowPassFilter(X_dtft, 0.3);  % Design filter with cutoff 0.3π
X_filtered = applyFilter(X_dtft, H, false); % Apply filter
magPlot(X_filtered, false, true, omega); % Plot filtered spectrum
```

### **Upsampling and Downsampling**
```matlab
[H_up, omega_up] = upsampleDTFT(X_dtft, omega, 2, true); % Upsample by 2
[H_down, omega_down] = downsampleDTFT(X_dtft, omega, 2, true); % Downsample by 2
```

### **Visualize Complex Spectra**
```matlab
plotReIm(X_dtft, false, omega); % 3D plot of real/imaginary components
```

## **Example Scripts**
- **Example1.m** - Demonstrates aliasing effects in downsampling.
- **ExampleNoiseRemoval.m** - Shows noise removal using frequency-domain filtering.
- **ExampleFFT.m** - Compares FFT and DTFT approaches.

## **License**
This toolbox is open-source under the **MIT License**.

## **Contributions & Support**
Feel free to contribute via **GitHub pull requests** or report issues.
For questions, contact **ethanwedo@gmail.com**.

**Happy Signal Processing!**

