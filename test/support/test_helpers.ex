defmodule Rumbl.TestHelpers do
    alias Rumbl.Repo

    @doc """
    Inserts a mock user to be used throughout the tests
    """
    def insert_user(attrs \\ %{}) do
        changes = Dict.merge(%{
            name: "Some user",
            username: "user#{Base.encode16(:crypto.rand_bytes(8))}",
            password: "canttouchthis"
        }, attrs)

        %Rumbl.User{}
        |> Rumbl.User.registration_changeset(changes)
        |> Repo.insert!()
    end

    @doc """
    Inserts a mock video to be used throughout the tests
    """
    def insert_video(user, attrs \\ %{}) do
        user
        |> Ecto.build_assoc(:videos, attrs)
        |> Repo.insert!()
    end
end