defmodule Ttl120 do
@moduledoc "Модуль определяет функционал удаление записи из БД
            поcле отображения в соответствии со значением TTL"
require Logger
  @doc "Функция удаления записи после отображения по истечении TTL"
  def del120(key, ttl) do
    receive do
      [key, ttl] ->
        Logger.info("Начинаем отсчет #{ttl} секунд")
        :timer.sleep(ttl*1000)
        Logger.info("Отсчет закончен")
      try do
       {:atomic, [record]} = :mnesia.transaction(fn ->
       :mnesia.delete({:kvs, key}) end)
      rescue
        error -> error
      end
      Logger.info("Запись по ключу #{key} успешно удалена через #{ttl} секунд.")
    end
  end

end
