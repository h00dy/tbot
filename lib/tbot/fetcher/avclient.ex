defmodule Tbot.Fetcher.AVClient do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://www.alphavantage.co/"
  plug Tesla.Middleware.Headers, [{"authorization", "token xyz"}]
  plug Tesla.Middleware.JSON

  def get_intraday(symbol, interval \\ 60) do
    api_key = System.fetch_env!("API_KEY")

    {:ok, response} =
      get(
        "query?function=TIME_SERIES_INTRADAY&symbol=#{symbol}&interval=#{interval}min&outputsize=full&apikey=#{
          api_key
        }"
      )

    response.body
  end
end
