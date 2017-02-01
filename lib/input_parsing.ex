defmodule FilePile.InputParsing do
  import FilePile.WeightFile
  def get_args(args, argname) do
    args
    |> parse_args
    |> List.keytake(argname, 0)
    |> extract_from_keytake
  end
  
  def parse_args(args) do
    {switch_args, _ , _} = OptionParser.parse(args)
    switch_args    
  end
  
  def extract_from_keytake({{_,value}, _}), do: value
  
  def file_to_lines_list(path_to_file, headers?) do
    file = 
      path_to_file
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
  def parse_weights_file(path_to_file, number_of_files, first_parsing_term) do
    file_as_list = 
      file_to_lines_list(path_to_file, true) 
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

  def to_tuple(map, first_term, second_term) do
    term = 
      Map.get(map, first_term)
    weight = 
      Map.get(map, second_term)
      |> String.to_integer
    {term, weight}
  end

end
