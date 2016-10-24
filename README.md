# FilePile

FilePile creates N random files, based on a given size profile and containing some random combination of input words. It's intended use is for generating test files for load testing purposes. An example word list (name here) and size profile (name here) have been included in this repo. 
## Installation
FilePile uses escript to generate an executable. You must have elixir and erlang installed on your machine. 
To generate this executable:

    ```
    git clone https://github.com/mycroftHo/file_pile.git
    cd file_pile
    mix deps.get
    mix escript.build
    ```
## Usage
To generate you files run the following command in the same directory where you generated the executable:
    ```
    ./filepile --weights "weights.csv" --n NumberOfFiles --outdir "outputdirectory" --words "inputwords"
    ```
