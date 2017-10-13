defmodule Router do

@moduledoc "Модуль определяет функционал роутера Plug.
            Реализуем GET, POST, PUT, Delete методы обращения к контенту БД"
  use Plug.Router #подключаем макросы

  alias Plug_VerifyRequest

  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  plug Plug_VerifyRequest, fields: ["nik", "name", "age", "games", "wins", "ttl"],
                      path: ["/upload"],
                      fields_del: ["nik"],
                      path_del: ["/delete"],
                      path_changes: ["/changes"]

  plug :match # подключаем встроенный модуль
  plug :dispatch # подключаем встроенный модуль Serv.zapros("#{nik}")

  get "/:nik", do: send_resp(conn, 200,  List.to_string(List.delete_at(Tuple.to_list(Serv.zapros("#{nik}")),0)) ) # Обработка запроса к родительскому узлу
  post "/upload", do: send_resp(conn, 201, "Upload complete\n")
  delete "/delete", do: send_resp(conn, 403, "delete complete\n")
  put "/changes", do: send_resp(conn, 205, "changes complete\n")
  match _, do: send_resp(conn, 404, "Oops!\n") # Обработка всех остальных запросов
end
