defmodule Rumbl.Category do
  use Rumbl.Web, :model

  schema "categories" do
    field :name, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end

  @doc """
  Appends criteria to order the categories alphabetically to a query
  """
  def alphabetical(query) do
    fro c in query, order_by: c.name
  end

  @doc """
  Appends criteria to limit the result to the category's name and id
  """
  def names_and_ids(query) do
    from c in query, select: {c.name, c.id}
  end
end
