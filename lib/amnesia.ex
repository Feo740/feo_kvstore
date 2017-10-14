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

  @doc "Функция записи в БД начальных значений"
  def wr_database do
  :mnesia.transaction(fn ->
    :mnesia.write({:kvs, "abc", "folk", 30})
    :mnesia.write({:kvs, "def", "rock", 20})
    :mnesia.write({:kvs, "ghj", "pop", 25})
  end)
  end

  @doc "Функция чтения записей из БД по ключевому полю"
  @spec rd_database(string()) :: tuple()
  def rd_database(key) do
   try do
    {:atomic, [record]} = :mnesia.transaction(fn ->
                                                :mnesia.read({:kvs, key}) end)
    ttl = List.last(Tuple.to_list(record))
    data = List.first(List.delete_at(List.delete_at(Tuple.to_list(record), 0), 0))
    pid = spawn(Ttl120, :del120, [key, ttl])
    send(pid, [key, ttl])
    List.to_string([data])
   rescue
     error -> error
   end
  end

  @doc "Функция останова БД"
  def stop_database do
    :mnesia.stop()
  end

  @doc "Функция удаления строки из БД"
  def del_item_database(params) do
    t_key = Map.get(params, "key")
        try do
          {:atomic, [record]} = :mnesia.transaction(fn ->
          :mnesia.delete({:kvs, t_key}) end)
        rescue
          error -> error
        end
  end

  @doc "функция изменения строки в БД"
  def change_item_database(params) do
    t_key = Map.get(params, "key")
    Map.delete(params, "key")
      {:atomic, [record]} = :mnesia.transaction(fn ->
                                               :mnesia.read({:kvs, t_key}) end)
    record = List.delete_at(List.delete_at((Tuple.to_list(record)),0), 0)
    if (Map.has_key?(params,"data")) do
      t_data = Map.get(params, "data")
    else
      t_data = List.first(record)
    end
    if (Map.has_key?(params,"ttl")) do
      t_ttl = String.to_integer(Map.get(params, "ttl"))
    else
      t_ttl = String.to_integer(List.first(List.delete_at(record, 0)))
    end
    :mnesia.transaction(fn ->:mnesia.write({:kvs, t_key, t_data, t_ttl}) end)
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
      end
  end

  @doc "Функция добавления строки в таблицу по http"
  def add_to_database_http(params) do
    key = Map.get(params, "key")
    data = Map.get(params, "data")
    ttl = String.to_integer(Map.get(params, "ttl"))
    :mnesia.transaction(fn ->:mnesia.write({:kvs, key, data, ttl}) end)
  end

end
