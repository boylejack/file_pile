defmodule FilePile do
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
    Enum.map(file_specs, fn(file_specification) -> generate_output(file_specification, words_list, output_dir) end)

    convert_files(output_dir)

    IO.puts "Done!"
  end
  
  def convert_files(output_dir) do
    IO.puts "Creating pdf documents"
    :os.cmd(String.to_char_list("(cd #{output_dir})"))
    IO.puts :os.cmd(String.to_char_list("(cd #{output_dir}; for i in #{output_dir}/*.tex; do lualatex $i; done)"))
    IO.puts "Cleaning up"
    
    :os.cmd(String.to_char_list("(cd #{output_dir}; rm #{output_dir}/*.tex)"))
    :os.cmd(String.to_char_list("(cd #{output_dir}; rm #{output_dir}/*.aux)"))
    :os.cmd(String.to_char_list("(cd #{output_dir}; rm #{output_dir}/*.log)"))
   
    IO.puts "Creating Word Documents"
  
    :os.cmd(String.to_char_list("(cd #{output_dir}; for j in *.txt; do soffice --headless --convert-to docx:\"MS Word 2007 XML\" $j; done)"))
    :os.cmd(String.to_char_list("(cd #{output_dir}; rm *.txt)"))
    :os.cmd(String.to_char_list("(cd #{output_dir}; for f in *.text; do mv -- \"$f\" \"${f%.text}.txt\"; done)"))
  end  

  def get_args(args, argname) do
    args
    |> parse_args
    |> List.keytake(argname, 0)
    |> extract_from_keytake
  end

  def generate_output({type, size}, words_list, dir) do
    case type do
      "pdf" -> generate_pdf(String.to_integer(size), words_list, dir)
      "doc" -> generate_doc(String.to_integer(size), words_list, dir)
      _ -> generate_txt(String.to_integer(size), words_list, dir)
    end
  end

  def generate_pdf(size, words_list, dir) do
    #tex will be converted by pdf later
    name = dir <> "/" <> UUID.uuid1() <> ".tex"
    preamble = "\\documentclass{article}\n\\begin{document}\n"
    ending = "\n\\end{document}"
    newline = "\n\\\\par"
    write_out_to_file(preamble, ending, newline, false, name, size, words_list)
  end
 
  def generate_doc(size, words_list, dir) do
    #txt is a temporary name, we will convert this at the end 
    name = dir <> "/" <> UUID.uuid1() <> ".txt"
    write_out_to_file("", "", "\n", false, name, size, words_list)
  end

  def generate_txt(size, words_list, dir) do
    #text is a temporary name, this will be converted at the end
    name = dir <> "/" <> UUID.uuid1() <> ".text"
    write_out_to_file("", "", "\n", false, name, size, words_list)
  end
  
  def write_out_to_file(preamble, ending, newline ,file_created, file, size, words_list) do
    if file_created == false do
      {:ok, new_file} = File.open file, [:write]
      IO.binwrite new_file, preamble
      write_out_to_file(preamble, ending, newline, true, new_file, size, words_list)
    end

    if size <= 0 and file_created == true do
      IO.binwrite file, ending
      File.close file
    end
    if size >= 0 and file_created == true do
      word_to_write = Enum.fetch!(words_list, :rand.uniform(Enum.count(words_list)) - 1) 
      IO.binwrite file, word_to_write
      #Every fifty words write a new line
      #Otherwise a space
      case :rand.uniform(50) do
        10 -> IO.binwrite file, newline
        _ -> IO.binwrite file, " "
      end
      write_out_to_file(preamble, ending, newline, true, file, size - 1 - byte_size(word_to_write), words_list)
    end
  end

  def file_to_lines_list(args, arg_name, headers?) do
    file = 
      (get_args(args, arg_name))
      |> File.stream!
      |> CSV.decode(headers: headers?)

    row_count = 
      file
      |> Enum.count

    file_as_list = 
      file
      |> Enum.take(row_count)
    
    file_as_list
  end

  #returns a list of terms from a term-weight file
  def parse_weights_file(args, arg_name, number_of_files, first_parsing_term) do
    file_as_list = 
      file_to_lines_list(args, arg_name, true) 
      |> Enum.map(fn maps -> to_tuple(maps, first_parsing_term, "weight") end)

    {first_term_list, weights_list} = Enum.unzip(file_as_list)
    intervals_list = weights_to_intervals(weights_list)
    
    terms = 
      random_intervals(number_of_files, (List.last(intervals_list) + 1))
      |> intervals_to_indexes(intervals_list)
      |> indexes_to_sizes(first_term_list)
  end

  def to_string_list([]) do
    []
  end

  def to_string_list([h|t]) do
    [hd(h)] ++ to_string_list(t)
  end

  def indexes_to_types([], _) do
    []
  end

  def indexes_to_types(indexes, type_list) do
    [Enum.fetch!(type_list, hd(indexes))] ++ indexes_to_types(tl(indexes), type_list) 
  end

  def indexes_to_sizes([], _) do
    []
  end

  def indexes_to_sizes(indexes, size_list) do
    [Enum.fetch!(size_list, hd(indexes))] ++ indexes_to_sizes(tl(indexes), size_list) 
  end

  def intervals_to_indexes([], _) do
    []
  end

  def intervals_to_indexes([h|t], list_of_intervals) do
    [Enum.find_index(list_of_intervals, fn(x) -> h <= x end)] ++ intervals_to_indexes(t, list_of_intervals)
  end

  def random_intervals(0, biggest_interval) do
    []
  end

  def random_intervals(n, biggest_interval) do
    [:rand.uniform(biggest_interval) - 1] ++ random_intervals((n-1), biggest_interval)
  end

#TODO refactor entirely
  def to_tuple(map, first_term, second_term) do
    term = 
      Map.get(map, first_term)
    weight = 
      Map.get(map, second_term)
      |> String.to_integer
    {term, weight}
  end

  def parse_args(args) do
    {switch_args, _ , _} = OptionParser.parse(args)
    switch_args    
  end

  def weights_to_intervals(weights) do
    weights_to_intervals(weights, 0)
  end

  def weights_to_intervals([], _) do
    []
  end
  
  def weights_to_intervals([h|t], 0) do
    [h-1] ++ weights_to_intervals(t, h-1)
  end

  def weights_to_intervals([h|t], acc) do
    [h+acc] ++ weights_to_intervals(t, h+acc)
  end  

  def extract_from_keytake({{_,value}, _}), do: value
  
  def find_interval([], number_to_find, index) do
    index
  end

  def find_interval(intervals, number_to_find, index) do
    if number_to_find <= hd(intervals) do
      index
    else
      find_interval(tl(intervals), number_to_find, index + 1)
    end
  end

end
