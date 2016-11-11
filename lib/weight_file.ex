defmodule FilePile.WeightFile do
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
