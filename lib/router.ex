defmodule Router do

@moduledoc "Модуль определяет функционал роутера Plug.
            Реализуем GET, POST, PUT, Delete методы обращения к контенту БД"
  use Plug.Router #подключаем макросы

  #alias Plug_VerifyRequest

  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  #plug Plug_VerifyRequest, fields: ["key", "data", "ttl"],
                      #path: ["/upload"],
                      #fields_del: ["key"],
                      #path_del: ["/delete"],
                      #path_changes: ["/changes"]

  plug :match # подключаем встроенный модуль
  plug :dispatch # подключаем встроенный модуль Serv.zapros("#{nik}")

  get "/:key", do: send_resp(conn, 200,  List.to_string(List.delete_at(Tuple.to_list(Serv.zapros("#{key}")),0))) # Обработка запроса к родительскому узлу
  post "/:key", do: send_resp(conn, 201, upload(conn))
  delete "/delete", do: send_resp(conn, 403, "delete complete\n")
  put "/changes", do: send_resp(conn, 205, "changes complete\n")
  match _, do: send_resp(conn, 404, "Oops!\n") # Обработка всех остальных запросов

  def upload(conn) do
    #Amn.add_to_database_http(body_params, key)
    #"Upload complete\n"
    #Plug.Conn.read_body(conn, [])
    key = List.to_string(Map.get(conn, :path_info))
    data = Map.get(Map.get(conn, :body_params),"data")
    ttl = String.to_integer(Map.get(Map.get(conn, :body_params),"ttl"))
    Amn.add_to_database_http(key, data, ttl)
    "uploaded"
  end
end
