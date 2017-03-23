Rails.application.routes.draw do

  devise_for :users

  apipie
  root to: 'apipie/apipies#index'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'


  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :registrations, only: [] do
        collection do
          post :sign_up
          post :sing_up_social_media
          post :forgot_password
        end
      end
      resources :user_sessions do
        collection do
          post :login
          post :logout
        end
      end
      resources :member_profiles do
        collection do
          get 'get_following_requests'
          get 'get_followers_requests'
          get 'profile_timeline'
          get 'get_followers'
          get 'accepted_rejected_follower'
          get 'get_following_members'
          get 'get_profile'
          put 'profile_update'
        end
      end
      resources :events
      resources :posts do
        collection do
          get 'discover'
          get 'related_posts'
          get 'post_list'
          get 'post_likes_list'
          get 'post_comments_list'
          get 'auto_complete'
        end
      end
      resources :post_comments
      resources :member_followings do
        collection do
          get 'search_member'
          post 'follow_member'
          post 'unfollow_member'
        end
      end
      
    end
  end

  # root to: 'home#index'
  mount ActionCable.server => '/cable'
end