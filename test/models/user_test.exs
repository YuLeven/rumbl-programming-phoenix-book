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

    test "changeset does not accept longer than 20 characters usernames" do
        attrs = %{@valid_attrs | username: String.duplicate("a", 30)}
        assert {:username, "should be at most 20 character(s)"} in errors_on(%User{}, attrs)
    end
end