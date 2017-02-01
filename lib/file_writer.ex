defmodule FilePile.FileWriter do
  def create_files(file_specs, words_list, output_dir) do
    Enum.map(file_specs, fn(x) -> generate_output(x, words_list, output_dir) end)
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
    name = dir <> "/" <> UUID.uuid1() <> ".ptf"
    preamble = ""
    ending = "\n"
    newline = "\n"
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
      case File.open file, [:write] do
        {:ok, new_file} -> 
          File.open file, [:write]
          IO.binwrite new_file, preamble
          write_out_to_file(preamble, ending, newline, true, new_file, size, words_list)
        {:error, :enoent} ->
          [:red, "[ERROR] ", :red, "Output folder does not exist"]
          |> Bunt.puts
          System.halt(1)
        _ -> System.halt(1)
      end
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
  
  def convert_files(output_dir) do
    IO.puts "Creating pdf documents"
    :os.cmd(String.to_char_list("(cd #{output_dir})"))
    IO.puts :os.cmd(String.to_char_list("(cd #{output_dir}; parallel -j 10 soffice --headless --convert-to pdf:\"writer_pdf_Export\" ::: *.ptf)"))
    IO.puts "Cleaning up"
    IO.puts :os.cmd(String.to_char_list("(cd #{output_dir}; rm *.ptf)"))
    
   
    IO.puts "Creating Word Documents"
  
    :os.cmd(String.to_char_list("(cd #{output_dir}; for j in *.txt; do soffice --headless --convert-to docx:\"MS Word 2007 XML\" $j; done)"))
    :os.cmd(String.to_char_list("(cd #{output_dir}; rm *.txt)"))
    :os.cmd(String.to_char_list("(cd #{output_dir}; for f in *.text; do mv -- \"$f\" \"${f%.text}.txt\"; done)"))
  end  
end
