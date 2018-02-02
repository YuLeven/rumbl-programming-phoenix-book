defmodule Rumbl.UserTest do
    use Rumbl.ModelCase, async: true
    alias Rumbl.User

    @valid_attrs %{name: "Cookiemonster", username: "morecookies", password: "doughandchocolate"}
    @invalid_attrs %{}

    test "cahngeset with valid attributes" do
        changeset = User.changeset(%User{}, @valid_attrs)
        assert changeset.valid?
    end

    test "cahngeset with invalid attributes" do
        changeset = User.changeset(%User{}, @invalid_attrs)
        refute changeset.valid?
    end
end