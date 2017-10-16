defmodule Amn do

@moduledoc "В данном модуле создаем схему базы данных (create_database),
              таблицу, запускаем БД(start_database),
              записываем в нее начальные данные(wr_database),
              определяем функцию чтения из БД по ключевому полю(rd_database),
              функция останова БД (stop_database),Функция удаления строки из БД (del_item_database)
              Функция изменения строки БД (change_item_database)."

  @doc "Функция создания шаблона БД"
  def create_database do
    :mnesia.create_schema([node()])#создаем БД,в рабочем кат.
                                  #появится папка Mnesia.nonode@nohost
                                  #в этом каталоге созд файл schema.DAT
    :mnesia.create_table(:kvs,[{:disc_copies,[node()]},{:attributes,[:key, :data, :ttl]}])
  end

  @doc "Функция запуска БД"
  def start_database do
    :mnesia.start()
  end

  @doc "Функция чтения записей из БД по ключевому полю из командной строки"
  def rd_database(key) do
   try do
    {:atomic, [record]} = :mnesia.transaction(fn ->
                                                :mnesia.read({:kvs, key}) end)
  #  ttl = List.last(Tuple.to_list(record))
    data = List.first(List.delete_at(List.delete_at(Tuple.to_list(record), 0), 0))
    List.to_string([data])
   rescue
     error -> "404"
     end
  end

  @doc "Функция останова БД"
  def stop_database do
    :mnesia.stop()
  end

  @doc "Функция внесения новой записи в БД из командной строки."
  def add_to_database do
      receive do
      msg ->  IO.puts("Now you can add item to the storage!")
            :timer.sleep(2_000)
            key = String.trim(IO.gets("Insert key:")) # Trim для отбрасывания хвоста /n
            data = String.trim(IO.gets("Insert data:"))
            ttl = String.to_integer(String.trim(IO.gets("Insert ttl:")))
            :mnesia.transaction(fn ->:mnesia.write({:kvs, key, data, ttl}) end)
            pid = spawn(Ttl120, :del120, [key, ttl])
            send(pid, [key, ttl])
      end
  end
end
