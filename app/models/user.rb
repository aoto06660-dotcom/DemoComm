class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :projects
  has_many :uploaded_audio_versions,
           class_name: "AudioVersion",
           foreign_key: :uploaded_by_id,
           inverse_of: :uploaded_by

  has_many :comments, dependent: :destroy

  validates :name, presence: :true
  validates :email, presence: :true,
                    uniqueness: { case_sensitive: false }
end
