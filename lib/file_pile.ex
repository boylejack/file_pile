defmodule FilePile do
  import FilePile.InputParsing
  import FilePile.FileWriter

  def main(args) do
    output_dir = 
      get_args(args, :outdir)

    words_list = 
      file_to_lines_list(args, :words, false)
      |> to_string_list

    number_of_files = 
      get_args(args, :n)
      |> String.to_integer

    sizes = parse_weights_file(args, :weights, number_of_files, "size")

    types = parse_weights_file(args, :types, number_of_files, "type")

    file_specs = List.zip([types,sizes])
    IO.inspect file_specs

    IO.puts "Creating #{List.foldl(sizes, 0, fn(x, acc) -> String.to_integer(x) + acc end)} bytes of data"

    create_files(file_specs, words_list, output_dir)

    convert_files(output_dir)

    IO.puts "Done!"
  end
end
