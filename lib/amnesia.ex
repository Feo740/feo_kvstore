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
    :mnesia.create_table(:p_players,[{:disc_copies,[node()]},{:attributes,[:nikname, :name, :age, :games, :wins, :ttl]}])
  end

  @doc "Функция запуска БД"
  def start_database do
    :mnesia.start()
  end

  @doc "Функция записи в БД начальных значений"
  def wr_database do
  :mnesia.transaction(fn ->
    :mnesia.write({:p_players, "hat", "Bill Smith", "45", 100, 40, 30})
    :mnesia.write({:p_players, "bell", "Ann Pirson", "20", 10, 3, 20})
    :mnesia.write({:p_players, "Rat", "Den Konnie", "45", 75, 37, 25})
  end)
  end

  @doc "Функция чтения записей из БД по ключевому полю"
  @spec rd_database(string()) :: tuple()
  def rd_database(nik) do
   try do
    {:atomic, [record]} = :mnesia.transaction(fn ->
                                                :mnesia.read({:p_players, nik}) end)
    ttl = List.last(Tuple.to_list(record))
    pid = spawn(Ttl120, :del120, [nik, ttl])
    send(pid, [nik, ttl])
    string_parse(record)
   rescue
     error -> error
   end
  end

  @doc "Функция парсинга результатов :mnesia.read в
        строку для отображение на HTML страничке"
  def string_parse(record) do
    temp = List.delete_at(List.flatten(Tuple.to_list(record)),0)
    nik = List.first(temp)
    temp1 = List.delete_at(temp, 0)
    name = List.first(temp1)
    string_p = "We are leaving #{name} called #{nik}"
  end

  @doc "Функция останова БД"
  def stop_database do
    :mnesia.stop()
  end

  @doc "Функция удаления строки из БД"
  def del_item_database(params) do
    player_nik = Map.get(params, "nik")
        try do
          {:atomic, [record]} = :mnesia.transaction(fn ->
          :mnesia.delete({:p_players, player_nik}) end)
        rescue
          error -> error
        end
  end

  @doc "функция изменения строки в БД"
  def change_item_database(params) do
    player_nik = Map.get(params, "nik")
    Map.delete(params, "nik")
      {:atomic, [record]} = :mnesia.transaction(fn ->
                                               :mnesia.read({:p_players, player_nik}) end)
    record = List.delete_at(List.delete_at((Tuple.to_list(record)),0), 0)
    if (Map.has_key?(params,"name")) do
      player_name = Map.get(params, "name")
    else
      player_name = List.first(record)
    end
    if (Map.has_key?(params,"age")) do
      player_age = Map.get(params, "age")
    else
      player_age = List.first(List.delete_at(record, 0))
    end
    if (Map.has_key?(params,"ttl")) do
      player_ttl = Map.get(params, "ttl")
    else
      player_ttl = List.last(record)
    end
    if (Map.has_key?(params,"games")) do
      player_games = Map.get(params, "games")
    else
      player_games = List.first(List.delete_at(List.delete_at(record, 0), 0))
    end

    if (Map.has_key?(params,"wins")) do
      player_wins = Map.get(params, "wins")
    else
      player_wins = List.first(List.delete_at(List.delete_at(List.delete_at(record, 0),0), 0))
    end
    :mnesia.transaction(fn ->:mnesia.write({:p_players, player_nik, player_name, player_age, player_games, player_wins, player_ttl}) end)
  end

  @doc "Функция внесения новой записи в БД из командной строки."
  def add_to_database do
      receive do
      msg ->  IO.puts("Вам выпала честь дополнить нашу таблицу!")
            :timer.sleep(2_000)
            nik = String.trim(IO.gets("Введите ник игрока:")) # Trim для отбрасывания хвоста /n
            name = String.trim(IO.gets("Введите имя игрока:"))
            age = String.trim(IO.gets("Введите возраст игрока:"))
            games = String.to_integer(String.trim(IO.gets("Введите количество игр:")))
            wins = String.to_integer(String.trim(IO.gets("Введите количество побед:")))
            ttl = String.to_integer(String.trim(IO.gets("Введите время жизни записи:")))
            :mnesia.transaction(fn ->:mnesia.write({:p_players, nik, name, age, games, wins, ttl}) end)
      end
  end

  @doc "Функция добавления строки в таблицу по http"
  def add_to_database_http(params) do
    player_nik = Map.get(params, "nik")
    player_name = Map.get(params, "name")
    player_age = Map.get(params, "age")
    player_ttl = String.to_integer(Map.get(params, "ttl"))
    player_games = String.to_integer(Map.get(params, "games"))
    player_wins = String.to_integer(Map.get(params, "wins"))
    :mnesia.transaction(fn ->:mnesia.write({:p_players, player_nik, player_name, player_age, player_games, player_wins, player_ttl}) end)
  end

end
