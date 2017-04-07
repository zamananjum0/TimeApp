class AdminProfile < ApplicationRecord
  has_one :user, as: :profile

  def admin_profile(auth_token)
    member_profile = self.as_json(
        only:    [:id, :about, :photo],
        include: {
            user:    {
                only: [:id, :profile_id, :profile_type, :username, :email]
            }
        }).merge!(auth_token: auth_token).as_json
    { member_profile: member_profile }.as_json
  end
  def response_dashboard_index(member_profiles, member_groups, posts, post_comments)
    data = {
        profiles: member_profiles,
        groups:   member_groups,
        posts:    posts,
        comments: post_comments
    }

  end
end
