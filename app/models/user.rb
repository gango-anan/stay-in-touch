class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true, length: { maximum: 20 }

  has_many :posts
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  default_scope -> { order(:id) }

  has_many :direct_friendships, class_name: 'Bond', foreign_key: 'user_id', dependent: :destroy
  has_many :direct_friends, through: :direct_friendships, source: :friend
  has_many :confirmed_friendships,
           -> { where confirmed: true },
           class_name: 'Bond',
           foreign_key: 'friend_id', dependent: :destroy
  has_many :friends, through: :confirmed_friendships, source: :user

  def my_friendships
    direct_friendships + confirmed_friendships
  end

  def invite_to_friendship(user)
    direct_friends << user
  end

  def reject_friendship_request(user)
    friends.delete(user)
  end

  def my_friends
    direct_friends + friends
  end

  def check_if_my_friend(user)
    my_friends.include?(user)
  end

  def unconfirmed_sent_requests
    unconfirmed_sent_requests = direct_friendships.map { |friendship| friendship.friend unless friendship.confirmed }
    unconfirmed_sent_requests.compact
  end

  def confirmed_friends
    direct_friendships.map { |friendship| friendship.friend if friendship.confirmed }.compact
  end

  def unconfirmed_requests
    unconfirmed_sent_requests
  end
end
