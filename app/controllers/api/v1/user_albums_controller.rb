class Api::V1::UserAlbumsController < ApplicationController

  def show_album
    # params = {
    #   "auth_token": "24d13da419b8ce1138360e22c1f548e64f4b5379b2f9c4d2c6450f4c81f3cb6085d4a6f68f8471861144d87bc163205f01abc3559cd84be8f7f658bb1409151e0953e12c4239b587c43b4f638862ad740336e28846579cc70dfc17d7427fff74a3e12f84",
    #   "page": 1,
    #   "per_page": 10,
    #   "album":
    #     {
    #         "id": 1
    #     }
    # }

    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  UserAlbum.show_album(params, user_session.user)
      render json: resp_data
    else
      resp = {resp_data: {}, status: 0, message: 'error'}
      return render json: resp
    end
  end

  def add_images_to_album
    # params = {
    #   "auth_token": "24d13da419b8ce1138360e22c1f548e64f4b5379b2f9c4d2c6450f4c81f3cb6085d4a6f68f8471861144d87bc163205f01abc3559cd84be8f7f658bb1409151e0953e12c4239b587c43b4f638862ad740336e28846579cc70dfc17d7427fff74a3e12f84",
    #   "page": 1,
    #   "per_page": 10,
    #   "album":
    #     {
    #       "id": 1,
    #       "album_images_attributes":[
    #         {
    #             "attachment_url": "https://fusseo-staging.s3.amazonaws.com/fusseo/6D485C61-B55E-4E4B-800A-841D6EE67EC6/67ce81382f09f99eaa255c8ebb2e9c7663aebe618f94441a87f047955a886791a4ca47c1024f919e8a4aade1c1ac70cc41686254614a5df5a98e144f9f0933b83715003b2830e3d27aceef5fcb8361c5f3b2ca2117a67e50ec41ca5c857975f26cd8c66b/postThumb.png",
    #             "thumbnail_url": "https://fusseo-staging.s3.amazonaws.com/fusseo/6D485C61-B55E-4E4B-800A-841D6EE67EC6/67ce81382f09f99eaa255c8ebb2e9c7663aebe618f94441a87f047955a886791a4ca47c1024f919e8a4aade1c1ac70cc41686254614a5df5a98e144f9f0933b83715003b2830e3d27aceef5fcb8361c5f3b2ca2117a67e50ec41ca5c857975f26cd8c66b/postThumb.png"
    #         },
    #         {
    #             "attachment_url": "https://fusseo-staging.s3.amazonaws.com/fusseo/6D485C61-B55E-4E4B-800A-841D6EE67EC6/67ce81382f09f99eaa255c8ebb2e9c7663aebe618f94441a87f047955a886791a4ca47c1024f919e8a4aade1c1ac70cc41686254614a5df5a98e144f9f0933b83715003b2830e3d27aceef5fcb8361c5f3b2ca2117a67e50ec41ca5c857975f26cd8c66b/postThumb.png",
    #             "thumbnail_url": "https://fusseo-staging.s3.amazonaws.com/fusseo/6D485C61-B55E-4E4B-800A-841D6EE67EC6/67ce81382f09f99eaa255c8ebb2e9c7663aebe618f94441a87f047955a886791a4ca47c1024f919e8a4aade1c1ac70cc41686254614a5df5a98e144f9f0933b83715003b2830e3d27aceef5fcb8361c5f3b2ca2117a67e50ec41ca5c857975f26cd8c66b/postThumb.png"
    #         }
    #       ]
    #     }
    # }

    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  UserAlbum.add_images_to_album(params, user_session.user)
      render json: resp_data
    else
      resp = {resp_data: {}, status: 0, message: 'error'}
      return render json: resp
    end
  end

  def album_list
    # params = {
    #   "auth_token": "24d13da419b8ce1138360e22c1f548e64f4b5379b2f9c4d2c6450f4c81f3cb6085d4a6f68f8471861144d87bc163205f01abc3559cd84be8f7f658bb1409151e0953e12c4239b587c43b4f638862ad740336e28846579cc70dfc17d7427fff74a3e12f84",
    #   "page": 1,
    #   "per_page": 10
    # }

    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  UserAlbum.album_list(params, user_session.user)
      render json: resp_data
    else
      resp = {resp_data: {}, status: 0, message: 'error'}
      return render json: resp
    end
  end

  def edit_album
    # params = {
    #   "auth_token": "24d13da419b8ce1138360e22c1f548e64f4b5379b2f9c4d2c6450f4c81f3cb6085d4a6f68f8471861144d87bc163205f01abc3559cd84be8f7f658bb1409151e0953e12c4239b587c43b4f638862ad740336e28846579cc70dfc17d7427fff74a3e12f84",
    #   "album":
    #     {
    #         "id": 1
    #     }
    # }

    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data  =  UserAlbum.edit_album(params, user_session.user)
      render json: resp_data
    else
      resp = {resp_data: {}, status: 0, message: 'error'}
      return render json: resp
    end
  end

end
