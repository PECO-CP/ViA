# ViA - Viral Image Analysis
ViA is a MATLAB-based, open-source program for analyzing epifluorescence microscopy images of viral particles. The program can be run through MATLAB (on a Mac or PC) or can be downloaded as executable and run through the freely available MATLAB runtime environment.

## Overview of Program and Case Studies
The ViA program aims to provide an effective means for quantifying viral abundances from epifluorescence images as well as enumerating the intensity of a primary (e.g., SYBR Gold) and secondary stain (e.g., biorthogonal non-canonical amino acid tagging [BONCAT] or fluorescence in-situ hybridization [FISH]). The program enables the user to export data in easy-to-use formats, facilitating downstream analysis. You can find an overview of the functionality of the ViA program here [LINK TO BIORX].

The materials from the case study featured in the manuscript including microscopy images and suggested analyses are included in the 'Case Studies' folder within this repository. 

**The case study includes images from**
1) *Emiliania huxleyi* viruses (EhV)

## How to install and run programs
Detailed instructions for installing, running, and using ViA can be found in the manual located in the 'Manuals' folder within this repository. The manual also comes prepackaged with the program download.

**Quick Install Guide**

*MATLAB Version*
1. Download the ViA program files appropriate for your system (Mac or Windows).
2. Open MATLAB and navigate to the proper working directory (e.g., the folder you saved the script files in).
3. The scripts to run the program are organized into a series of MATLAB packages. They can be distinguished by the ’+’ present in every folder’s name. **The primary file to run is located in the ’+Interfaces’ package and is labelled 'viral_analysis.m.**
4. To run the program, you can either open up the ’viral_analysis’ file in the command window and click ’Run’ or run it from MATLAB’s command window by calling the script directly.

*Executable Version*
1. Download the ViA executable program appropriate to your system (Mac or Windows). 
2. Navigate to the location of the executable installer on your computer and open it. A pop-up may appear verifying the download with publisher ’Unknown’. Follow the instructions of the program, including selecting an installation location. Once you do so and accept the Mathworks licensing agreement, the download will begin. (NOTE: The program will not download the runtime environment if it detects it has already been downloaded). If needed, you can download the runtime environment [HERE]. *Please see the manaul for details about permissions that may be required for Mac users*
3. To run the program, the executable will be located within the ’application’ sub-folder of the folder you selected for installation. The program will either be an .exe or .app file depending if you installed it onto a PC or Mac, respectively. Double-click the .exe (or .app) file and the program will start up. 
