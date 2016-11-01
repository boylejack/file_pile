# FilePile

FilePile creates N random files, based on a given size and type profile and containing some random combination of input words. It's intended use is for generating test files for load testing purposes. An example word list (positive-words.csv), a size profile (some_weights.csv) and a type profile (types.csv) have been included in this repo. 
## Installation
FilePile uses escript to generate an executable. You must have elixir and erlang installed on your machine. 
To generate this executable:

    ```
    git clone https://github.com/mycroftHo/file_pile.git
    cd file_pile
    mix deps.get
    mix escript.build
    ```
    
*NB* This program requires you to have both pdflatex and libreoffice installed in order to generate word documents and pdfs.

## Usage
To generate you files run the following command in the same directory where you generated the executable:

    ```
    ./filepile --weights "weights.csv" --n 10 --outdir "outputdirectory" --words "inputwords.csv" --types "types.csv"
    ```
This will generate 10 files in the outputdirectory using weights.csv, types.csv and the inputwords list.
Please note that you should use full paths to files and directories when calling this script.

## Using Your Own Size Profile
The idea of FilePile is to create a number of files that mirror the intended file profile of your system. The size profile size is a CSV with two columns. One represents file size (in bytes) and the other is the likelihood of a file of that size appearing in your system.
So if you have two rows

| Size     | Weight |
| :-----:      | :-----:       |
| 10000 | 1   |
| 20000     | 2     |

There will be roughly twice as many 20kb files as 10kb files.

The type weights file is roughly similar but instead maps the likelihood of a given file type appearing in the resulting files. Currently filepile supports the creation of txt, .docx, and .pdf files. 
