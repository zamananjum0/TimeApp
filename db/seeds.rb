user_profile               = MemberProfile.create!(country_id: 1, city_id: 1)
user                       = user_profile.build_user
user.first_name            = "test"
user.last_name             = "test"
user.email                 = "test@gmail.com"
user.password              = "test123456"
user.password_confirmation = "test123456"
user.save!

