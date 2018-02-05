defmodule Rumbl.VideoChannel do
    use Rumbl.Web, :channel

    @doc """
    This callback is invoked every time a client attemps to join this channel
    Authorization can be handled through the atom returned in the
    first position of the tuple, :ok being allow and :error deny
    """
    def join("videos:" <> video_id, _params, socket) do
        {
            :ok, 
            socket |> assign(:video_id, String.to_integer(video_id))
        }
    end

    def handle_in("new_annotation", params, socket) do
        broadcast! socket, "new_annotation", %{
            user: %{username: "anon"},
            body: params["body"],
            at: params["at"]
        }

        {:reply, :ok, socket}
    end
end