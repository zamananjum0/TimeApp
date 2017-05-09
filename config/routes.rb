Rails.application.routes.draw do

  devise_for :users

  apipie
  root to: 'dashboards#index'

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
          get 'get_followers'
          get 'get_followings'
          get 'profile_timeline'
          get 'accepted_rejected_follower'
          get 'get_profile'
          put 'profile_update'
        end
      end
      resources :events do
        collection do
          get 'event_posts'
          get 'global_winners'
          get 'leaderboard_winners'
          get 'competitions'
          post 'block_event'
        end
      end
      resources :posts, only: [:index, :destroy] do
        collection do
          get 'post_list'
          get 'post_likes_list'
          get 'post_comments_list'
          post 're_post'
          get 'search_posts_and_members'
        end
      end
      resources :comments
      resources :member_followings do
        collection do
          get  'search_member'
          post 'follow_member'
          post 'unfollow_member'
        end
      end
      resources :groups do
        collection do
          post 'update_group'
          delete 'delete_group'
        end
      end
      # Routes for web
      resources :dashboards, only:[:index]
      resources :users, only:[:index] do
        collection do
          get 'user_posts'
          get 'user_followers'
          post 'block_user'
        end
      end
      resources :likes, only: [:index]
    end
  end

  # root to: 'home#index'
  mount ActionCable.server => '/cable'
end