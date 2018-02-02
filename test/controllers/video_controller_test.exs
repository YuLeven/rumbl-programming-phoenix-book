defmodule Rumbl.VideoControllerTest do
  use Rumbl.ConnCase

  alias Rumbl.Video
  @valid_attrs %{description: "陰と光", title: "Bad Apple", url: "https://www.youtube.com/watch?v=FtutLA63Cp8"}
  @invalid_attrs %{title: "invalid"}
  
  setup  %{conn: conn} = config do
    if username = config[:login_as] do
      user = insert_user(username: username)
      conn = assign(build_conn(), :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, video_path(conn, :new)),
        get(conn, video_path(conn, :index)),
        get(conn, video_path(conn, :show, "123")),
        get(conn, video_path(conn, :edit, "123")),
        get(conn, video_path(conn, :update, "123", %{})),
        get(conn, video_path(conn, :create, %{})),
        get(conn, video_path(conn, :delete, "123"))
      ], fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end

  @tag login_as: "Larry"
  test "lists all entries on index", %{conn: conn, user: user} do
    user_video = insert_video(user, title: "Chunky Bacon")
    other_user_video = insert_video(insert_user(username: "Charles"), title: "Smoky Bacon")

    conn = get conn, video_path(conn, :index)

    assert html_response(conn, 200) =~ "Listing videos"
    assert String.contains?(conn.resp_body, user_video.title)
    refute String.contains?(conn.resp_body, other_user_video.title)
  end

  @tag login_as: "Cookiemonster"
  test "creates user video and redirects", %{conn: conn, user: user} do
    conn = post conn, video_path(conn, :create), video: @valid_attrs
    assert redirected_to(conn) == video_path(conn, :index)
    assert Repo.get_by!(Video, @valid_attrs).user_id == user.id
  end

  @tag login_as: "Cookiemonster"
  test "fails to create a new video and render errors when invalid", %{conn: conn} do
    count_before = video_count(Video)
    conn = post conn, video_path(conn, :create), video: @invalid_attrs
    assert html_response(conn, 200) =~ "check the errors"
    assert video_count(Video) == count_before
  end

  @tag login_as: "Cookiemonster"
  test "renders form for new resources", %{conn: conn} do
    conn = get conn, video_path(conn, :new)
    assert html_response(conn, 200) =~ "New video"
  end

  @tag login_as: "Cookiemonster"
  test "shows chosen resource", %{conn: conn, user: user} do
    video = insert_video(user, title: "Chunky Bacon")
    conn = get conn, video_path(conn, :show, video)
    assert html_response(conn, 200) =~ "Show video"
  end

  @tag login_as: "Cookiemonster"
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, video_path(conn, :show, -1)
    end
  end

  @tag login_as: "Cookiemonster"
  test "renders form for editing chosen resource", %{conn: conn, user: user} do
    video = insert_video(user, title: "Chunky Bacon")
    conn = get conn, video_path(conn, :edit, video)
    assert html_response(conn, 200) =~ "Edit video"
  end

  @tag login_as: "Cookiemonster"
  test "updates chosen resource and redirects when data is valid", %{conn: conn, user: user} do
    video = insert_video(user, title: "Chunky Bacon")
    conn = put conn, video_path(conn, :update, video), video: @valid_attrs
    assert redirected_to(conn) == video_path(conn, :show, video)
    assert Repo.get_by!(Video, @valid_attrs)
  end

  @tag login_as: "Cookiemonster"
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
    video = insert_video(user, title: "Chunky Bacon")
    conn = put conn, video_path(conn, :update, video), video: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit video"
  end

  @tag login_as: "Cookiemonster"
  test "deletes chosen resource", %{conn: conn, user: user} do
    video = insert_video(user, title: "Chunky Bacon")
    conn = delete conn, video_path(conn, :delete, video)
    assert redirected_to(conn) == video_path(conn, :index)
    refute Repo.get(Video, video.id)
  end

  # Counts the total videos
  defp video_count(query), do: Repo.one(from v in query, select: count(v.id))
end
