defmodule Rumbl.Video do
  use Rumbl.Web, :model

  @primary_key {:id, Rumbl.Permalink, autgenerate: true}

  schema "videos" do
    field :url, :string
    field :title, :string
    field :description, :string
    field :slug, :string
    belongs_to :user, Rumbl.User
    belongs_to :category, Rumbl.Category

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:url, :title, :description, :category_id])
    |> slugify_title()
    |> validate_required([:url, :title, :description])
    |> assoc_constraint(:category)
  end

  # We override - I have no idea of how to call this in a functional programming language.
  # Is it the same? Anyway, we 'override' the Phoenix.Param implementation for this model
  # so params using the view 'link' macro matches our slug schema
  defimpl Phoenix.Param, for: Rumbl.Video do
    def to_param(%{slug: slug, id: id}) do
      "#{id}-#{slug}"
    end
  end

  defp slugify_title(changeset) do
    if title = get_change(changeset, :title) do
      put_change(changeset, :slug, slugify(title))
    else
      changeset
    end
  end

  defp slugify(str) do
    str
      |> String.downcase()
      |> String.replace(~r/[^\w-]+/u, "-")
  end
end
