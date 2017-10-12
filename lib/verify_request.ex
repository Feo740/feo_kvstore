defmodule Plug_VerifyRequest do
@moduledoc "Модуль определяет сценарий обработки http-запросов"
  defmodule IncompleteRequestError do
    @moduledoc " если у запроса отсутствует один из треб парамметров происходит исключение"
    defexception message: "", plug_status: 400 #Если этот параметр доступен модуль plug использует его,
    #чтобы установить код состояния для HTTP ответа в случае возникновения исключения
  end

  def init(options), do: options
  @doc "Определяем нужно ли вообще проверять данный запрос,
        если не срабатывает ни одно условие, просто пробрасываем структуру conn дальше."
  def call(%Plug.Conn{request_path: path} = conn, opts) do
    #вызываем функцию verify_request! только если путь запроса содержится в аргументе :paths
    if path in opts[:path], do: verify_req(conn.body_params, opts[:fields])
    if path in opts[:path_del], do: verify_req_del(conn.body_params, opts[:fields_del])
    if path in opts[:path_changes], do: Amn.change_item_database(conn.body_params)
    conn
  end

  @doc "функция проверяет наличие у запроса всех требуемых для добавления
        записи в БД параметров из аргумента :fields"
  defp verify_req(body_params, fields) do
    verified = body_params
              |> Map.keys
              |> contains_fields?(fields)
              Amn.add_to_database_http(body_params)
    unless verified, do: raise IncompleteRequestError
  end

  @doc "функция проверяет наличие у запроса всех требуемых для удаления
        записи из БД параметров из аргумента :fields_del"
  defp verify_req_del(body_params, fields) do
    verified = body_params
              |> Map.keys
              |> contains_fields?(fields)
              Amn.del_item_database(body_params)
    unless verified, do: raise IncompleteRequestError
  end

  @doc "Функция проверяет наличие полей по всем ключам"
  def contains_fields?(keys, fields), do: Enum.all?(fields, &(&1 in keys))

end
