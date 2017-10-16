defmodule D_apl do
  @moduledoc "Главный модуль приложения, является супервизором за servSUP - супервизором генсервера"
  use Application
  require Logger

 @doc "В рамках главного приложения запуск супервизора"
 def start(_type, _args) do
    port = Application.get_env(:example, :cowboy_port, 8080)
    # Plug.Adapters.Cowboy.child_spec третий аргумент передается в Example.HelloWorldPlug.init/1
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Router, [], port: port)
              ]
    Logger.info "Started application"
    Supervisor.start_link(children, strategy: :one_for_one)
    Supervisor.start_link(__MODULE__,[],[{:name,__MODULE__}])
  end

@doc "start_link запускает init где мы настраиваем параметры"
  def init([]) do
    import Supervisor.Spec, warn: false
    child = [supervisor(ServSUP,[],[])]

   supervise(child,[{:strategy,:one_for_one},{:max_restarts,1},{:max_seconds, 5}])
    #Supervisor.start_link(children, strategy: :one_for_one)
  end

  def zapros(key) do
    Serv.zapros(key)
  end

  def create_mnesia do
    Serv.create_mnesia
  end

  def start_database do
    Serv.start_database
  end

  def add_to_database do
    Serv.add_to_database
  end
end
