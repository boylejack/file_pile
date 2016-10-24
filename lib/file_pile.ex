defmodule FilePile do
  def main(args) do

    number_of_files = 
      args
      |> parse_args
      |> List.keytake(:n, 0)
      |> extract_from_keytake
      |> String.to_integer

    weights_size_file = 
      args
      |> parse_args
      |> List.keytake(:weights, 0)
      |> extract_from_keytake
      |> File.stream!
      |> CSV.decode(headers: true)

    weights_size_count = 
      weights_size_file
      |> Enum.count

    weights_size_list =
      weights_size_file
      |> Enum.take(weights_size_count)
      |> Enum.map(fn maps -> to_tuple(maps) end)

    {size_list, weight_list} = Enum.unzip(weights_size_list)
    intervals_list = weights_to_intervals(weight_list)

    
    intervals_random = random_intervals(number_of_files, (List.last(intervals_list) + 1))
    indexes = intervals_to_indexes(intervals_random, intervals_list)
    sizes = indexes_to_sizes(indexes, size_list)
    word_list = ["hello", "goodbye", "greetings"]
    Enum.map(sizes, fn(x) -> generate_string(x, word_list) end)
    |> IO.inspect
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
    # ++ intervals_to_indexes(tl(intervals_random), list_of_intervals)
  end

  def generate_string(size, word_list) do
    if size <= 0 do
      ""
    else
      next_word = Enum.fetch!(word_list, :rand.uniform(Enum.count(word_list)) - 1) 
      next_word <> " " <> generate_string(size - String.length(next_word), word_list)
    end

  end


  def random_intervals(0, biggest_interval) do
    []
  end

  def random_intervals(n, biggest_interval) do
    [:rand.uniform(biggest_interval) - 1] ++ random_intervals((n-1), biggest_interval)
  end

  def to_tuple(map) do
    size = 
      Map.get(map, "size")
      |> String.to_integer
    weight = 
      Map.get(map, "weight")
      |> String.to_integer
    {size, weight}
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
