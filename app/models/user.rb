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

  has_many :unconfirmed_friendships,
           -> { where confirmed: false },
           class_name: 'Bond', dependent: :destroy
  has_many :unconfirmed_friends, through: :unconfirmed_friendships, source: :friend

  has_many :confirmed_friendships,
           -> { where confirmed: true },
           class_name: 'Bond', dependent: :destroy
  has_many :confirmed_friends, through: :confirmed_friendships, source: :user

  has_many :unconfirmed_sent_invitations, -> { where confirmed: false }, class_name: 'Bond', foreign_key: 'friend_id'
  has_many :pending_friends, through: :unconfirmed_sent_invitations, source: :user
  
  def friends_and_own_posts
    Post.where(user: (self.confirmed_friends.to_a << self))
  end

  def unconfirmed_received_requests
    self.pending_friends.to_a
  end

  def unconfirmed_sent_requests
    self.unconfirmed_friends.to_a
  end
end
