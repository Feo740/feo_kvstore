defmodule ServSUP do
@moduledoc "Модуль определяет механику работы супервизора. ServSUP
               - это супервизор генсервера serv"
use Supervisor

  @doc "Запуск супервизора"
  def start_link do
    {:ok,pid} = Supervisor.start_link(__MODULE__,[],[{:name,__MODULE__}])
  end

  @doc "Обратный вызов Супервизора настраиваем процесс-воркер"
  def init([]) do
    child = [worker(Serv,[],[])]
    supervise(child,[{:strategy,:one_for_one},{:max_restarts,1},{:max_seconds, 5}])
  end

end
