defmodule FilePile do
  import FilePile.InputParsing
  import FilePile.FileWriter

  def main(args) do
    output_dir = 
      get_args(args, :outdir)

    config_file_path = System.cwd <> "/input_files"

    words_list = 
      file_to_lines_list(config_file_path <> "/input_words.csv", false)
      |> to_string_list

    number_of_files = 
      get_args(args, :n)
      |> String.to_integer

    sizes = parse_weights_file(config_file_path <> "/size_weights.csv", number_of_files, "size")

    types = parse_weights_file(config_file_path <> "/type_weights.csv", number_of_files, "type")

    file_specs = List.zip([types,sizes])
    IO.inspect file_specs

    IO.puts "Creating #{Sizeable.filesize(List.foldl(sizes, 0, fn(x, acc) -> String.to_integer(x) + acc end))} of data"

    create_files(file_specs, words_list, output_dir)

    convert_files(output_dir)

    IO.puts "Done!"
  end
end
