# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#

alias Rumbl.Repo
alias Rumbl.Category

for category <- ~w(Action Drama Romance Comedy Sci-fi) do
    Repo.insert!(%Category{name: category})
end