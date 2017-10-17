defmodule Router do

@moduledoc "Модуль определяет функционал роутера Plug.
            Реализуем GET, POST, PUT, Delete методы обращения к контенту БД"
  use Plug.Router #подключаем макросы

  plug Plug.Parsers, parsers: [:urlencoded, :multipart]

  plug :match # подключаем встроенный модуль
  plug :dispatch # подключаем встроенный модуль Serv.zapros("#{nik}")

  get "/:key", do: send_resp(conn, 200,  List.to_string(List.delete_at(Tuple.to_list(Serv.zapros("#{key}")),0))) # Обработка запроса к родительскому узлу
  post "/:key", do: send_resp(conn, 201, upload(conn))
  delete "/:key", do: send_resp(conn, 403, delete(conn))
  put "/:key", do: send_resp(conn, 205, put(conn))
  match _, do: send_resp(conn, 404, "Oops!\n") # Обработка всех остальных запросов

  @doc "Функция добавления строки в таблицу по http"
  @spec upload(Map) :: String.t
  def upload(conn) do
    fields = ["data", "ttl"]
    #IO.inspect(Enum.all?(fields, &(&1 in Map.keys(Map.get(conn, :body_params)))))
    if (Enum.all?(fields, &(&1 in Map.keys(Map.get(conn, :body_params))))) do
      key = List.to_string(Map.get(conn, :path_info))
      data = Map.get(Map.get(conn, :body_params),"data")
      ttl = String.to_integer(Map.get(Map.get(conn, :body_params),"ttl"))
      pid = spawn(Ttl120, :del120, [key, ttl])
      :mnesia.transaction(fn ->:mnesia.write({:kvs, key, data, ttl, pid}) end)
      send(pid, [key, ttl])
      "Key: #{key} uploaded data #{data} for #{ttl} seconds."
    else
      "not enough data"
    end

  end

  @doc "Функция удаления строки из БД"
  @spec delete(Map) :: String.t
  def delete(conn) do
    key = List.to_string(Map.get(conn, :path_info))
    try do
      {:atomic, [record]} = :mnesia.transaction(fn ->
                                               :mnesia.read({:kvs, key}) end)
      pid = List.last(Tuple.to_list(record))
      {:atomic, [record]} = :mnesia.transaction(fn ->
      :mnesia.delete({:kvs, key}) end)
      Process.exit(pid, :kill)
    rescue
      error -> error
    end
    "delete complete\n"
  end

  @doc "функция изменения строки в БД по http"
  @spec put(Map) :: String.t
  def put(conn) do
    key = List.to_string(Map.get(conn, :path_info))
    {:atomic, [record]} = :mnesia.transaction(fn ->
                                             :mnesia.read({:kvs, key}) end)
    pid = List.last(Tuple.to_list(record))
    record = List.delete_at(List.delete_at((Tuple.to_list(record)),0), 0)
    if (Map.has_key?(Map.get(conn, :body_params),"data")) do
      data = Map.get(Map.get(conn, :body_params),"data")
    else
      data = List.first(record)
    end
    if (Map.has_key?(Map.get(conn, :body_params),"ttl")) do
      ttl = String.to_integer(Map.get(Map.get(conn, :body_params),"ttl"))
      Process.exit(pid, :kill)
    else
      ttl = List.first(List.delete_at(record, 0))
    end
    pid = spawn(Ttl120, :del120, [key, ttl])
    :mnesia.transaction(fn ->:mnesia.write({:kvs, key, data, ttl, pid}) end)
    send(pid, [key, ttl])
    "Key: #{key} changed data #{data} for #{ttl} seconds."
    "changed complete"
  end

end
