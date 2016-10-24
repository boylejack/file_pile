# FilePile

FilePile creates N random files, based on a given size profile and containing some random combination of input words. It's intended use is for generating test files for load testing purposes. An example word list (name here) and size profile (name here) have been included in this repo. 
## Installation
FilePile uses escript to generate an executable. To generate this executable:

  1. Add `file_pile` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:file_pile, "~> 0.1.0"}]
    end
    ```
