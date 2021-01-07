defmodule Kundi.Router do
  use Plug.Router

  alias Plug.Conn

  @typep assigns :: keyword()
  @typep layout :: String.t()
  @typep template :: String.t()

  @template_dir "lib/kundi/templates"

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_template(conn, "application", "form", game: false)
  end

  get "/play" do
    %{params: params} = conn = Conn.fetch_query_params(conn)

    assigns =
      params
      |> Kundi.join_game()
      |> Kundi.handle_event(params)
      |> Kundi.get_opponents()

    send_template(conn, "application", "play", assigns)
  end

  match _ do
    conn |> Conn.put_status(:not_found) |> send_template("application", "not_found", [])
  end

  @spec send_template(Conn.t(), layout, template, assigns) :: Conn.t() | no_return()
  defp send_template(conn, layout, template, assigns) do
    send_template(conn, layout, [{:inner_content, render(layout, template, assigns)} | assigns])
  end

  @spec send_template(Conn.t(), layout, assigns) :: Conn.t() | no_return()
  defp send_template(%{status: status} = conn, layout, assigns) do
    send_resp(conn, status || 200, render(layout, "index", assigns))
  end

  @spec render(layout, template, assigns) :: any
  defp render(layout, template, assigns) do
    [@template_dir, layout, template]
    |> Path.join()
    |> String.replace_suffix("", ".html.eex")
    |> EEx.eval_file(assigns: assigns)
  end
end
