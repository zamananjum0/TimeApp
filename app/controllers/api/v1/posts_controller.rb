class Api::V1::PostsController < ApplicationController
  @@limit = 10

  def discover
    # params ={
    #   auth_token: "d3bb2b7b15943a3b013dbc3095d652e9c364cb0b75f53fa4dca5ccdcb2596a8af9d398d5d6bb5b58f4650f95bf1742a113c14e7624fb8170f604521a19170c96f23cdff5668e5b85c7177066d0aad445ad6776c103ab595fde7c21d9488b8681f3cbe9df",
    #   "per_page": 10,
    #   "page": 1,
    #   "search":
    #     {
    #       "key": "first one",
    #       "type": "Post"
    #     }
    #
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data = Post.discover(params, user_session.user)
      render json: resp_data
    else
      resp_data = {resp_status: 0, message: 'Invalid Token', error: '', data: {}}
      return render json: resp_data
    end
  end

  def post_list
    # params ={
    #   auth_token: "d3bb2b7b15943a3b013dbc3095d652e9c364cb0b75f53fa4dca5ccdcb2596a8af9d398d5d6bb5b58f4650f95bf1742a113c14e7624fb8170f604521a19170c96f23cdff5668e5b85c7177066d0aad445ad6776c103ab595fde7c21d9488b8681f3cbe9df",
    #   "per_page": 10,
    #   "page": 1,
    #   "min_post_date": "2017-02-010 23:20:47 +0500 "
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data = Post.post_list(params, user_session.user)
      render json: resp_data
    else
      resp_data = {resp_status: 0, message: 'Invalid Token', error: '', data: {}}
      return render json: resp_data
    end
  end

  def post_likes_list
    # params ={
    #   auth_token: "d3bb2b7b15943a3b013dbc3095d652e9c364cb0b75f53fa4dca5ccdcb2596a8af9d398d5d6bb5b58f4650f95bf1742a113c14e7624fb8170f604521a19170c96f23cdff5668e5b85c7177066d0aad445ad6776c103ab595fde7c21d9488b8681f3cbe9df",
    #   "per_page": 10,
    #   "page": 1,
    #   "post":
    #     {
    #         "id": 1
    #     }
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data = PostLike.post_likes_list(params, user_session.user)
      render json: resp_data
    else
      resp_data = {resp_status: 0, message: 'Invalid Token', error: '', data: {}}
      return render json: resp_data
    end
  end

  def post_comments_list
    # params ={
    #   auth_token: "24d13da419b8ce1138360e22c1f548e64f4b5379b2f9c4d2c6450f4c81f3cb6085d4a6f68f8471861144d87bc163205f01abc3559cd84be8f7f658bb1409151e0953e12c4239b587c43b4f638862ad740336e28846579cc70dfc17d7427fff74a3e12f84",
    #   "per_page": 10,
    #   "page": 1,
    #   "min_post_date": "2016-07-15T14:44:12.908Z",
    #   "post":
    #     {
    #         "id": 1
    #     }
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data = PostComment.post_comments_list(params, user_session.user)
      render json: resp_data
    else
      resp_data = {resp_status: 0, message: 'Invalid Token', error: '', data: {}}
      return render json: resp_data
    end
  end

  def auto_complete
    # params ={
    #     auth_token: "24d13da419b8ce1138360e22c1f548e64f4b5379b2f9c4d2c6450f4c81f3cb6085d4a6f68f8471861144d87bc163205f01abc3559cd84be8f7f658bb1409151e0953e12c4239b587c43b4f638862ad740336e28846579cc70dfc17d7427fff74a3e12f84",
    #     "key": "GO"
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data = Hashtag.auto_complete(params, user_session.user)
      render json: resp_data
    else
      resp_data = {resp_status: 0, message: 'Invalid Token', error: '', data: {}}
      return render json: resp_data
    end
  end




  # Not ok
  def related_posts
    # params ={
    #   auth_token: "24d13da419b8ce1138360e22c1f548e64f4b5379b2f9c4d2c6450f4c81f3cb6085d4a6f68f8471861144d87bc163205f01abc3559cd84be8f7f658bb1409151e0953e12c4239b587c43b4f638862ad740336e28846579cc70dfc17d7427fff74a3e12f84",
    #   "per_page": 10,
    #   "page": 1,
    #   "post": {
    #       "id": 1
    #   }
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data = Post.related_posts(params, user_session.user)
      render json: resp_data
    else
      resp_data = {resp_status: 0, message: 'Invalid Token', error: '', data: {}}
      return render json: resp_data
    end
  end

end
