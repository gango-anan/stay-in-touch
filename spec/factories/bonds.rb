FactoryBot.define do
  factory :bond do
    user_id { 1 }
    friend_id { 1 }
    state { 'following' }
  end
end
