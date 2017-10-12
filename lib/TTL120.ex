defmodule Ttl120 do
@moduledoc "Модуль определяет функционал удаление записи из БД
            поcле отображения в соответствии со значением TTL"
require Logger
  @doc "Функция удаления записи после отображения по истечении TTL"
  def del120(nik, ttl) do
    receive do
      [nik, ttl] ->
        Logger.info("Начинаем отсчет #{ttl} секунд")
        :timer.sleep(ttl*1000)
        Logger.info("Начинаем отсчет закончен")
      try do
       {:atomic, [record]} = :mnesia.transaction(fn ->
       :mnesia.delete({:p_players, nik}) end)
      rescue
        error -> error
      end
      Logger.info("Запись #{nik} успешно удалена через #{ttl} секунд.")
    end
  end

end
