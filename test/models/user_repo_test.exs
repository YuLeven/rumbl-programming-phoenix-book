defmodule Rumbl.UserRepoTest do
    use Rumbl.ModelCase
    alias Rumbl.User

    @valid_attrs %{name: "Cookiemonster", username: "cookies"}

    test "converts unique_constraint on username to error" do
        insert_user(username: "le_phantome")
        attrs = %{@valid_attrs | username: "le_phantome"}
        changeset = User.changeset(%User{}, attrs)

        assert {:error, changeset} = Repo.insert(changeset)
        assert {:username, {"has already been taken", []}} in changeset.errors
    end
end