require "test/test_helper"

class Admin::PostsControllerTest < ActionController::TestCase

  should "render index and validates_presence_of_custom_partials" do
    get :index
    assert_match "posts#_index.html.erb", @response.body
  end

  should "render_index_and_verify_page_title" do
    get :index
    assert_select "title", "Posts"
  end

  should "render index_and_show_add_entry_link" do
    get :index
    assert_select "#sidebar ul" do
      assert_select "li", "Add new"
    end
  end

  should "render_index_and_not_show_add_entry_link" do
    typus_user = typus_users(:designer)
    @request.session[:typus_user_id] = typus_user.id

    get :index
    assert_response :success

    assert_no_match /Add Post/, @response.body
  end

  should "render_index_and_show_trash_item_image" do
    get :index
    assert_response :success
    assert_select '.trash', 'Trash'
  end

  should "render_index_and_not_show_trash_image" do
    typus_user = typus_users(:designer)
    @request.session[:typus_user_id] = typus_user.id

    get :index

    assert_response :success
    assert_select ".trash", false
  end

  should "get_index_and_render_edit_or_show_links" do
    %w(edit show).each do |action|
      Typus::Resource.expects(:default_action_on_item).at_least_once.returns(action)
      get :index
      Post.all.each do |post|
        assert_match "/posts/#{action}/#{post.id}", @response.body
      end
    end
  end

  should "get_index_and_render_edit_or_show_links_on_owned_records" do
    typus_user = typus_users(:editor)
    @request.session[:typus_user_id] = typus_user.id

    get :index

    Post.all.each do |post|
      action = post.owned_by?(typus_user) ? "edit" : "show"
      assert_match "/posts/#{action}/#{post.id}", @response.body
    end
  end

  should "get_index_and_render_edit_or_show_on_only_user_items" do
    typus_user = typus_users(:editor)
    @request.session[:typus_user_id] = typus_user.id

    %w(edit show).each do |action|

      Typus::Resource.stubs(:only_user_items).returns(true)
      Typus::Resource.stubs(:default_action_on_item).returns(action)

      get :index

      Post.all.each do |post|
        if post.owned_by?(typus_user)
          assert_match "/posts/#{action}/#{post.id}", @response.body
        else
          assert_no_match /\/posts\/#{action}\/#{post.id}/, @response.body
        end
      end

    end

  end

  ##
  # get :new
  ##

  should "render new and partials_on_new" do
    get :new
    assert_match "posts#_new.html.erb", @response.body
  end

  should "render new and verify page title" do
    get :new
    assert_select "title", "New Post"
  end

  ##
  # get :edit
  ##

  should "render_edit_and_verify_presence_of_custom_partials" do
    get :edit, { :id => posts(:published).id }
    assert_match "posts#_edit.html.erb", @response.body
  end

  should "render_edit_and_verify_page_title" do
    get :edit, { :id => posts(:published).id }
    assert_select "title", "Edit Post"
  end

  ##
  # get :show
  ##

  should "render_show_and_verify_presence_of_custom_partials" do
    get :show, { :id => posts(:published).id }
    assert_match "posts#_show.html.erb", @response.body
  end

  should "render_show_and_verify_page_title" do
    get :show, { :id => posts(:published).id }
    assert_select "title", "Show Post"
  end

end